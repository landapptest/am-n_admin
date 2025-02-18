/* functions/index.js */

const {onValueCreated, onValueUpdated} =
 require("firebase-functions/v2/database");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * (1) 새 사용자 문서가 "users/{uid}"에 만들어졌을 때
 *     isApproved = false 이면, 관리자에게 알림
 */
exports.onUserCreate = onValueCreated({
  ref: "projects/_/instances/chattingbin-14523-default-rtdb/refs/users/{uid}",
  region: "asia-southeast1"},
async (event) => {
  const uid = event.params.uid;
  const userData = event.data.value; // 새로 생성된 users/{uid}의 전체 데이터

  // "새 user"가 생성된 순간 only
  if (userData.isApproved === false) {
    const tokensSnap = await admin.database().ref("adminTokens").
        once("value");
    if (!tokensSnap.exists()) {
      console.log("[onUserCreate] 관리자 토큰 없음");
      return;
    }
    const tokensObj = tokensSnap.val();
    const tokens = Object.values(tokensObj);

    const payload = {
      notification: {
        title: "새 학생증 승인 요청",
        body: `이름: ${userData.userName || "이름 미상"}, UID: ${uid}`,
      },
    };

    const resp = await admin.messaging().sendToDevice(tokens, payload);
    console.log("[onUserCreate] 관리자 알림 응답:", resp);
  }
});

/**
 * (2) 기존 "users/{uid}" 데이터가 수정되었을 때
 *     isApproved=false -> isApproved=true 로 바뀌면, 해당 사용자에게 승인 알림
 */
exports.onUserApprove = onValueUpdated({
  ref: "projects/_/instances/chattingbin-14523-default-rtdb/refs/users/{uid}",
  region: "asia-southeast1"},
async (event) => {
  const beforeData = event.data.before.value || {};
  const afterData = event.data.value || {};
  const uid = event.params.uid;

  // "데이터가 수정"된 상황
  // 이전 isApproved=false 이고, 이후 isApproved=true 이면 승인
  if (beforeData.isApproved === false && afterData.isApproved === true) {
    const tokenSnap = await admin.database()
        .ref(`users/${uid}/fcmToken`)
        .once("value");
    if (!tokenSnap.exists()) {
      console.log("[onUserApprove] 사용자 토큰 없음");
      return;
    }
    const userToken = tokenSnap.val();

    const payload = {
      notification: {
        title: "승인 완료",
        body: `${afterData.userName || "사용자"}님, 학생증 승인되었습니다!`,
      },
    };

    const resp = await admin.messaging().sendToDevice(userToken, payload);
    console.log("[onUserApprove] 사용자 알림 응답:", resp);
  }
});
