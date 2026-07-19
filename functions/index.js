// silent observer tht watch db for changes
// sends noti to caregivers when patient crosses missed-dose threshold

// fires whenever log created/chged
const {onDocumentWritten} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");

initializeApp();
const db = getFirestore();

// alert fires when the patient reaches exactly this many missed doses today
const MISSED_THRESHOLD = 3;


// uses Written instead of Created to also include
// log that underwent status update (e.g., pending -> missed)
exports.onMissedDose = onDocumentWritten(
    "adherenceLogs/{logId}",
    // run this func whenever logs are created/updated/dlted,
    // {logId} = wildcard, any log

    // ----------------- check if it's a newly missed dose -----------------

    async (event) => { // event = doc being created/updated/dlted
      const after = event.data && event.data.after && event.data.after.data();
      const before =
      event.data && event.data.before && event.data.before.data();
      // event.data = event payload (data), if don't have, return null
      // event.data.after = does event have state aft change,
      //                    events like delete x have, return null
      // event.data.after.data() = data aft change

      // if null/anything that isn't a "missed" log, return
      if (!after) return;
      if (after.status !== "missed") return;

      // check if bfr already a missed, only react to genuine transition
      // re-writes missed logs on every app reopen,
      // without this guard the alert re-fires each time.
      if (before && before.status === "missed") return;


      // ------------- get details to count num of times missed --------------

      // get details of log frm data
      const patientId = after.userId;
      const medId = after.medicationId;
      const logDate = after.date; // Firestore Timestamp at midnight of the day

      // count this patient's missed logs for that same day
      const missedSnap = await db.collection("adherenceLogs")
          .where("userId", "==", patientId)
          .where("medicationId", "==", medId)
          .where("status", "==", "missed")
          .where("date", "==", logDate)
          .get();
      const missedCount = missedSnap.size;

      // fire when num of missed dose is >= 3 or a multiple of 3
      if (missedCount % MISSED_THRESHOLD !== 0) return;


      // ----------------- get details to form message -----------------

      // patient's name for the message
      const patientDoc = await db.collection("users").doc(patientId).get();
      const patientName =
      (patientDoc.data() && patientDoc.data().name) || "Your patient";

      // medication name of the missed dose
      const medDoc = await db.collection("medications").doc(medId).get();
      const medName = (medDoc.data() && medDoc.data().name) || "a medication";

      // find caregivers linked to this patient
      const relsSnap = await db.collection("caregiverRelationships")
          .where("patientId", "==", patientId)
          .get();

      // ----------------- send noti -----------------

      // send a push + write an in-app notification for each caregiver
      const pushes = []; // {caregiverId, token, promise}
      const writes = []; // in-app notification doc writes

      // find every caregiver's fcm token
      // get caregiver id -> caregiver obj using id -> caregiver fcm token
      for (const relDoc of relsSnap.docs) {
        const caregiverId = relDoc.data().caregiverId;
        const cgDoc = await db.collection("users").doc(caregiverId).get();
        const token = cgDoc.data() && cgDoc.data().fcmToken;

        // in-app notification
        writes.push(
            db.collection("notifications").add({
              userId: caregiverId,
              type: "alert",
              title: "Missed medication alert",
              message: `${patientName} has missed ${medName} ` +
            `${missedCount} times today.`,
              timestamp: new Date(),
              read: false,
            }),
        );

        if (!token) continue; // rerun for loop to fetch again if no token

        pushes.push({
          caregiverId,
          token,
          promise: getMessaging().send({
            token: token,
            notification: {
              title: "Repeatedly Missed Medication Alert",
              body: `${patientName} has missed ${missedCount} ` +
              `doses of ${medName} today.`,
            },
            android: {
              priority: "high",
              notification: {
              // match channel id created in the app
                channelId: "caregiver_alerts",
              },
            },
          }),
        });
      }

      // ----------------- process results & clean up -----------------

      // allSettled so one bad token can't fail the whole batch
      const [, ...pushResults] = await Promise.all([
        Promise.allSettled(writes), // write noti to db collection
        ...pushes.map((p) => p.promise.then( // send noti to each caregiver
        // added to pushResults based on case
            () => ({status: "ok"}),
            (err) => ({status: "error", err, entry: p}),
        )),
      ]);

      // prune tokens Firebase reports as no longer registered
      // so future alerts don't keep failing on a dead device
      const cleanups = [];
      for (const r of pushResults) {
        if (r.status === "error") {
          const code = r.err && r.err.code;
          console.error(
              `Push to ${r.entry.caregiverId} failed: ${code || r.err}`,
          );

          // clean up invalid/unregistered tokens
          if (
            code === "messaging/registration-token-not-registered" ||
          code === "messaging/invalid-registration-token"
          ) {
            cleanups.push( // fcm token empty, remove push noti
                db.collection("users").doc(r.entry.caregiverId)
                    .set({fcmToken: ""}, {merge: true}),
            );
          }
        }
      }
      await Promise.allSettled(cleanups);

      // print how many noti successfully sent based on status "ok"
      const ok = pushResults.filter((r) => r.status === "ok").length;
      console.log(
          `Sent ${ok}/${pushes.length} push(es) + ` +
      `${writes.length} in-app alert(s) for patient ${patientId} ` +
      `(${missedCount} missed doses of ${medName} today).`,
      );
    },
);
