import db from "../utils/db.js";

export const getAllCategories = (req, res) => {
  db.query("SELECT * FROM categories", (err, data) => {
    try {
      res.status(200).json({
        message: "Get all categories success",
        data: data,
      });
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  });
};

export const createCategory = (req, res) => {
  const { name, isExpense } = req.body;
  db.query(
    "INSERT INTO categories (name, isExpense) VALUES (?, ?)",
    [name, isExpense],
    (err, data) => {
      try {
        res.status(201).json({
          message: "Category ditambahkan",
          data: data,
        });
      } catch (err) {
        res.status(500).json({ message: err.message });
      }
    }
  );
};

export const updateCategory = (req, res) => {
  const { id } = req.params;
  const { name, isExpense } = req.body;
  db.query(
    "UPDATE categories SET name = ?, isExpense = ? WHERE id = ?",
    [name, isExpense, id],
    (err, data) => {
      try {
        res.status(200).json({
          message: "Category diubah!",
        });
      } catch (err) {
        res.status(500).json({ message: err.message });
      }
    }
  );
};

export const deleteCategory = (req, res) => {
  const { id } = req.params;
  db.query("DELETE FROM categories WHERE id = ?", [id], (err, data) => {
    try {
      res.status(200).json({
        message: "Category dihapus!",
      });
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  });
};
