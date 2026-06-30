import { useState } from "react";
import {
  InitiateAuthCommand,
  RespondToAuthChallengeCommand,
} from "@aws-sdk/client-cognito-identity-provider";
import { cognitoClient, CLIENT_ID } from "./cognito";
import Cookies from "js-cookie";
import CryptoJS from "crypto-js";

const ENCRYPTION_KEY = "your-secret-key-32chars-minimum!";

function Login({ onLogin }) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [mfaCode, setMfaCode] = useState("");
  const [session, setSession] = useState(null);

  const handleLogin = async () => {
    const command = new InitiateAuthCommand({
      AuthFlow: "USER_PASSWORD_AUTH",
      ClientId: CLIENT_ID,
      AuthParameters: {
        USERNAME: email,
        PASSWORD: password,
      },
    });

    try {
      const response = await cognitoClient.send(command);
      console.log("レスポンス", response);

      if (response.ChallengeName === "EMAIL_OTP") {
        setSession(response.Session);
      }
    } catch (err) {
      console.error("ログイン失敗", err);
    }
  };

  const handleMfa = async () => {
    const command = new RespondToAuthChallengeCommand({
      ClientId: CLIENT_ID,
      ChallengeName: "EMAIL_OTP",
      Session: session,
      ChallengeResponses: {
        USERNAME: email,
        EMAIL_OTP_CODE: mfaCode,
      },
    });

    try {
      const response = await cognitoClient.send(command);
      console.log("MFA成功", response);

      const { AccessToken, IdToken, RefreshToken } =
        response.AuthenticationResult;

      // アクセストークンとIDトークンだけ暗号化して保存
      const tokens = { accessToken: AccessToken, idToken: IdToken };
      const encrypted = CryptoJS.AES.encrypt(
        JSON.stringify(tokens),
        ENCRYPTION_KEY,
      ).toString();
      const expiry = Date.now() + 60 * 60 * 1000; // 60分後のミリ秒

      console.log("暗号化後の長さ:", encrypted.length);
      Cookies.set("session", encrypted, { expires: 1 / 24 }); // 1時間
      Cookies.set("refresh", RefreshToken, { expires: 1 });
      Cookies.set("expiry", expiry, { expires: 1 / 24 });
      onLogin();
      console.log("cookieに保存しました");
    } catch (err) {
      console.error("MFA失敗", err);
    }
  };

  return (
    <div>
      <h1>ログイン</h1>
      <input
        type="email"
        placeholder="メールアドレス"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
      />
      <input
        type="password"
        placeholder="パスワード"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
      />
      <button onClick={handleLogin}>ログイン</button>
      {session && (
        <div>
          <input
            type="text"
            placeholder="otp"
            value={mfaCode}
            onChange={(e) => setMfaCode(e.target.value)}
          />
          <button onClick={handleMfa}>認証</button>
        </div>
      )}
    </div>
  );
}

export default Login;
