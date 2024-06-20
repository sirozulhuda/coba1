import express from "express";
import {
  getAllTransactions,
  createTransaction,
  updateTransaction,
  deleteTransaction,
} from "../controller/transactionController.js";

const router = express.Router();

router.get("/transactions", getAllTransactions);
router.post("/transactions", createTransaction);
router.put("/transactions/:id", updateTransaction);
router.delete("/transactions/:id", deleteTransaction);

export default router;
