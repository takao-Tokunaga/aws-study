import Link from 'next/link';

export default function Home() {
  return (
    <div style={{ textAlign: 'center', paddingTop: 60 }}>
      <h2>タスク管理</h2>
      <Link href="/tasks" style={{ padding: '12px 24px', background: '#0070f3', color: '#fff', borderRadius: 6, textDecoration: 'none' }}>
        タスク一覧へ
      </Link>
    </div>
  );
}
