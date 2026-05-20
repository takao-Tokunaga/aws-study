import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Task Manager',
  description: 'タスク管理アプリ',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ja">
      <body style={{ fontFamily: 'sans-serif', margin: 0, padding: '0 20px', background: '#f5f5f5' }}>
        <header style={{ background: '#fff', padding: '16px 20px', boxShadow: '0 1px 3px rgba(0,0,0,0.1)', marginBottom: 24 }}>
          <h1 style={{ margin: 0, fontSize: 20 }}>Task Manager</h1>
        </header>
        <main style={{ maxWidth: 900, margin: '0 auto' }}>{children}</main>
      </body>
    </html>
  );
}
