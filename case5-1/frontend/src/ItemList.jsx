import { useEffect, useState } from "react";
import Cookies from "js-cookie";
import CryptoJS from "crypto-js";

const ENCRYPTION_KEY = "your-secret-key-32chars-minimum!";
const API_URL =
  "https://dwb8ua2tn3.execute-api.ap-northeast-1.amazonaws.com/prod/items";
function ItemList() {
  const [items, setItems] = useState([]);

  useEffect(() => {
    const fetchItems = async () => {
      // cookieから暗号化されたセッションを取り出す
      const encrypted = Cookies.get("session");
      console.log("cookie:", encrypted);
      if (!encrypted) return;

      // 復号してアクセストークンを取り出す
      const decrypted = CryptoJS.AES.decrypt(encrypted, ENCRYPTION_KEY);
      const tokens = JSON.parse(decrypted.toString(CryptoJS.enc.Utf8));
      console.log("accessToken:", tokens.accessToken);

      // APIを叩く
      const response = await fetch(API_URL, {
        headers: {
          Authorization: `Bearer ${tokens.idToken}`,
        },
      });
      const data = await response.json();
      setItems(data.items || []);
    };
    fetchItems();
  }, []);

  return (
    <div>
      <h1>アイテム一覧</h1>
      <ul>
        {items.map((item) => (
          <li key={item.id}>
            {item.name} - {item.price}円
          </li>
        ))}
      </ul>
    </div>
  );
}

export default ItemList;
