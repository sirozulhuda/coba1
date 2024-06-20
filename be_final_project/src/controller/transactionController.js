import db from "../utils/db.js";

export const getAllTransactions = (req, res) => {
  const query = `
    SELECT 
      t.id AS id,
      t.amount,
      t.transaction_date,
      t.description,
      t.isExpense,
      c.id AS category_id,
      c.name AS category_name
    FROM 
      transactions t
    LEFT JOIN 
      categories c ON t.category_id = c.id
  `;

  db.query(query, (err, data) => {
    if (err) {
      return res.status(500).json({ message: err.message });
    }

    res.status(200).json({
      message: "Get all transactions success",
      data: data,
    });
  });
};

export const createTransaction = (req, res) => {
  const { amount, transaction_date, description, category_id, isExpense } =
    req.body;
  const query =
    "INSERT INTO transactions (amount, description, transaction_date, category_id, isExpense) VALUES (?, ?, ?, ?, ?)";
  db.query(
    query,
    [amount, description, transaction_date, category_id, isExpense],
    (err, data) => {
      if (err) {
        console.error("Database error:", err);
        return res
          .status(500)
          .json({ message: "Database error: " + err.message });
      }
      res.status(201).json({
        message: "Transaksi ditambahkan",
        data: data,
      });
    }
  );
};

export const updateTransaction = (req, res) => {
  const { id } = req.params;
  const { amount, description, transaction_date, category_id, isExpense } =
    req.body;
  const query =
    "UPDATE transactions SET amount = ?, description = ?, transaction_date = ?, category_id = ?, isExpense = ? WHERE id = ?";
  db.query(
    query,
    [amount, description, transaction_date, category_id, isExpense, id],
    (err, result) => {
      if (err) {
        return res.status(500).json({ message: err.message });
      }
      res.status(200).json({
        message: "Transaksi diubah!",
      });
    }
  );
};

export const deleteTransaction = (req, res) => {
  const { id } = req.params;
  if (!id) {
    return res.status(400).json({ message: "Id transaksi tidak ditemukan" });
  }
  const query = "DELETE FROM transactions WHERE id = ?";
  db.query(query, [id], (err, result) => {
    if (err) {
      return res.status(500).json({ message: err.message });
    }
    res.status(200).json({
      message: "Transaksi dihapus!",
    });
  });
};
