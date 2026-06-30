import Login from "./Login";
import { useState, useEffect } from "react";
import Cookies from "js-cookie";
import ItemList from "./ItemList";

function App() {
  const [loggedIn, setLoggedIn] = useState(!!Cookies.get("session"));
  const [timeLeft, setTimeLeft] = useState("");

  useEffect(() => {
    if (!loggedIn) return;

    const expiry = Number(Cookies.get("expiry"));
    const remaining = expiry - Date.now(); // 残りミリ秒

    if (remaining <= 0) {
      setTimeout(() => {
        Cookies.remove("session");
        Cookies.remove("refresh");
        Cookies.remove("expiry");
        setLoggedIn(false);
      }, 0);
      return;
    }

    const interval = setInterval(() => {
      const now = Date.now();
      const rem = expiry - now;
      const m = Math.floor(rem / 1000 / 60);
      const s = Math.floor((rem / 1000) % 60);
      setTimeLeft(`${m}:${String(s).padStart(2, "0")}`);
    }, 1000);

    const timer = setTimeout(() => {
      // ログアウト処理 (cookieを消してstateを更新)
      Cookies.remove("session");
      Cookies.remove("refresh");
      Cookies.remove("expiry");
      setLoggedIn(false);
    }, remaining);

    return () => {
      clearTimeout(timer);
      clearInterval(interval);
    };
  }, [loggedIn]);

  return loggedIn ? (
    <>
      <p>ログアウト残り時間: {timeLeft}</p>
      <ItemList />
    </>
  ) : (
    <Login onLogin={() => setLoggedIn(true)} />
  );
}

export default App;
