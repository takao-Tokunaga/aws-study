'use client';

import { useState, useEffect, useRef } from 'react';

type TaskStatus = 'pending' | 'in_progress' | 'done';

interface Task {
  id: number;
  title: string;
  description?: string;
  status: TaskStatus;
  pictureUrl?: string;
  createdAt: string;
}

const API = process.env.NEXT_PUBLIC_API_URL ?? '/api';

const statusLabel: Record<TaskStatus, string> = {
  pending:     '未着手',
  in_progress: '進行中',
  done:        '完了',
};

const statusColor: Record<TaskStatus, string> = {
  pending:     '#888',
  in_progress: '#f59e0b',
  done:        '#10b981',
};

export default function TasksPage() {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [loading, setLoading] = useState(true);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [imageFile, setImageFile] = useState<File | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const fileRef = useRef<HTMLInputElement>(null);

  const fetchTasks = async () => {
    setLoading(true);
    try {
      const res = await fetch(`${API}/tasks`);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      setTasks(await res.json());
    } catch (e) {
      console.error('Failed to fetch tasks:', e);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchTasks(); }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim()) return;
    setSubmitting(true);

    try {
      let picture_s3_key: string | undefined;

      // 画像がある場合: presigned URL 発行 → S3 直接 PUT
      if (imageFile) {
        const urlRes = await fetch(`${API}/tasks/upload-url`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ filename: imageFile.name }),
        });
        const { uploadUrl, key } = await urlRes.json();
        await fetch(uploadUrl, { method: 'PUT', body: imageFile });
        picture_s3_key = key;
      }

      await fetch(`${API}/tasks`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ title, description, pictureS3Key: picture_s3_key }),
      });

      setTitle('');
      setDescription('');
      setImageFile(null);
      if (fileRef.current) fileRef.current.value = '';
      await fetchTasks();
    } finally {
      setSubmitting(false);
    }
  };

  const updateStatus = async (id: number, status: TaskStatus) => {
    await fetch(`${API}/tasks/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ status }),
    });
    await fetchTasks();
  };

  const deleteTask = async (id: number) => {
    if (!confirm('削除しますか？')) return;
    await fetch(`${API}/tasks/${id}`, { method: 'DELETE' });
    await fetchTasks();
  };

  const [exporting, setExporting] = useState(false);

  const exportCsv = async () => {
    setExporting(true);
    try {
      const res = await fetch(`${API}/exports`, { method: 'POST' });
      const job = await res.json();
      let jobId: number = job.id;

      // ステータスが complete になるまでポーリング（最大60秒）
      for (let i = 0; i < 30; i++) {
        await new Promise(r => setTimeout(r, 2000));
        const statusRes = await fetch(`${API}/exports/${jobId}`);
        const j = await statusRes.json();
        if (j.status === 'complete' && j.downloadUrl) {
          const a = document.createElement('a');
          a.href = j.downloadUrl;
          a.download = `tasks-${jobId}.csv`;
          a.click();
          return;
        }
        if (j.status === 'failed') {
          alert('CSVエクスポートに失敗しました');
          return;
        }
      }
      alert('タイムアウトしました。しばらくして再度お試しください。');
    } catch (e) {
      console.error('Export error:', e);
      alert('エクスポートエラーが発生しました');
    } finally {
      setExporting(false);
    }
  };

  return (
    <div>
      {/* 新規作成フォーム */}
      <div style={{ background: '#fff', padding: 24, borderRadius: 8, marginBottom: 24, boxShadow: '0 1px 3px rgba(0,0,0,0.1)' }}>
        <h2 style={{ marginTop: 0 }}>新規タスク</h2>
        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          <input
            value={title}
            onChange={e => setTitle(e.target.value)}
            placeholder="タイトル *"
            style={{ padding: '8px 12px', borderRadius: 4, border: '1px solid #ddd', fontSize: 14 }}
            required
          />
          <textarea
            value={description}
            onChange={e => setDescription(e.target.value)}
            placeholder="説明（任意）"
            rows={3}
            style={{ padding: '8px 12px', borderRadius: 4, border: '1px solid #ddd', fontSize: 14, resize: 'vertical' }}
          />
          <div>
            <label style={{ fontSize: 13, color: '#666' }}>画像（任意）</label>
            <input type="file" accept="image/*" ref={fileRef} onChange={e => setImageFile(e.target.files?.[0] ?? null)} style={{ display: 'block', marginTop: 4 }} />
          </div>
          <button
            type="submit"
            disabled={submitting}
            style={{ padding: '10px 20px', background: '#0070f3', color: '#fff', border: 'none', borderRadius: 4, cursor: 'pointer', fontSize: 14, width: 120 }}
          >
            {submitting ? '作成中...' : '作成'}
          </button>
        </form>
      </div>

      {/* CSV エクスポート */}
      <div style={{ marginBottom: 16, textAlign: 'right' }}>
        <button
          onClick={exportCsv}
          disabled={exporting}
          style={{ padding: '8px 16px', background: '#10b981', color: '#fff', border: 'none', borderRadius: 4, cursor: 'pointer', fontSize: 14 }}
        >
          {exporting ? 'エクスポート中...' : 'CSV出力'}
        </button>
      </div>

      {/* タスク一覧 */}
      {loading ? (
        <p>読み込み中...</p>
      ) : tasks.length === 0 ? (
        <p style={{ color: '#888' }}>タスクがありません</p>
      ) : (
        <div style={{ display: 'grid', gap: 16 }}>
          {tasks.map(task => (
            <div key={task.id} style={{ background: '#fff', padding: 20, borderRadius: 8, boxShadow: '0 1px 3px rgba(0,0,0,0.1)', display: 'flex', gap: 16 }}>
              {task.pictureUrl && (
                <img src={task.pictureUrl} alt="task" style={{ width: 80, height: 80, objectFit: 'cover', borderRadius: 4, flexShrink: 0 }} />
              )}
              <div style={{ flex: 1 }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                  <h3 style={{ margin: '0 0 4px' }}>{task.title}</h3>
                  <button onClick={() => deleteTask(task.id)} style={{ background: 'none', border: 'none', color: '#f44', cursor: 'pointer', fontSize: 18 }}>×</button>
                </div>
                {task.description && <p style={{ margin: '4px 0', color: '#555', fontSize: 14 }}>{task.description}</p>}
                <div style={{ marginTop: 8, display: 'flex', gap: 8, alignItems: 'center' }}>
                  <span style={{ color: statusColor[task.status], fontWeight: 'bold', fontSize: 13 }}>
                    ● {statusLabel[task.status]}
                  </span>
                  <select
                    value={task.status}
                    onChange={e => updateStatus(task.id, e.target.value as TaskStatus)}
                    style={{ padding: '4px 8px', borderRadius: 4, border: '1px solid #ddd', fontSize: 13 }}
                  >
                    {Object.entries(statusLabel).map(([v, l]) => (
                      <option key={v} value={v}>{l}</option>
                    ))}
                  </select>
                </div>
                <p style={{ margin: '4px 0 0', color: '#aaa', fontSize: 12 }}>
                  {new Date(task.createdAt).toLocaleString('ja-JP')}
                </p>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
