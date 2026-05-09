const express = require('express');
const router  = express.Router();
const db      = require('../db');

// GET /api/tasks?status=pending|in_progress|done
router.get('/', async (req, res) => {
    try {
        const { status } = req.query;
        let sql    = 'SELECT * FROM tasks ORDER BY created_at DESC';
        const params = [];
        if (status) {
            sql    = 'SELECT * FROM tasks WHERE status = ? ORDER BY created_at DESC';
            params.push(status);
        }
        const [rows] = await db.execute(sql, params);
        res.json(rows.map(toTask));
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// GET /api/tasks/:id
router.get('/:id', async (req, res) => {
    try {
        const [rows] = await db.execute('SELECT * FROM tasks WHERE id = ?', [req.params.id]);
        if (rows.length === 0) return res.status(404).json({ message: 'タスクが見つかりません' });
        res.json(toTask(rows[0]));
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// POST /api/tasks
router.post('/', async (req, res) => {
    try {
        const { title, description, status = 'pending' } = req.body;
        if (!title) return res.status(400).json({ message: 'titleは必須です' });
        const [result] = await db.execute(
            'INSERT INTO tasks (title, description, status) VALUES (?, ?, ?)',
            [title, description ?? null, status]
        );
        const [rows] = await db.execute('SELECT * FROM tasks WHERE id = ?', [result.insertId]);
        res.status(201).json(toTask(rows[0]));
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// PUT /api/tasks/:id
router.put('/:id', async (req, res) => {
    try {
        const { title, description, status } = req.body;
        if (!title) return res.status(400).json({ message: 'titleは必須です' });
        const [check] = await db.execute('SELECT id FROM tasks WHERE id = ?', [req.params.id]);
        if (check.length === 0) return res.status(404).json({ message: 'タスクが見つかりません' });
        await db.execute(
            'UPDATE tasks SET title = ?, description = ?, status = ? WHERE id = ?',
            [title, description ?? null, status ?? 'pending', req.params.id]
        );
        const [rows] = await db.execute('SELECT * FROM tasks WHERE id = ?', [req.params.id]);
        res.json(toTask(rows[0]));
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// DELETE /api/tasks/:id
router.delete('/:id', async (req, res) => {
    try {
        const [check] = await db.execute('SELECT id FROM tasks WHERE id = ?', [req.params.id]);
        if (check.length === 0) return res.status(404).json({ message: 'タスクが見つかりません' });
        await db.execute('DELETE FROM tasks WHERE id = ?', [req.params.id]);
        res.status(204).send();
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

function toTask(row) {
    return {
        id:          row.id,
        title:       row.title,
        description: row.description,
        status:      row.status,
        createdAt:   row.created_at,
        updatedAt:   row.updated_at,
    };
}

module.exports = router;
