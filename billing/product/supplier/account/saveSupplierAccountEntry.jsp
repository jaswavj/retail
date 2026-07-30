<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");

try {
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        out.print("{\"success\":false,\"message\":\"Session expired. Please login again.\"}");
        return;
    }

    String supIdStr  = request.getParameter("supplierId");
    String entryType = request.getParameter("entryType");
    String cashStr   = request.getParameter("cashPaid");
    String bankStr   = request.getParameter("bankPaid");
    String modeStr   = request.getParameter("payMode");
    String typeStr   = request.getParameter("payType");
    String amountStr = request.getParameter("amount");
    String notes     = request.getParameter("notes");

    if (supIdStr == null || entryType == null) {
        out.print("{\"success\":false,\"message\":\"Missing required parameters.\"}");
        return;
    }

    int supplierId = Integer.parseInt(supIdStr.trim());
    String type = entryType.trim().toUpperCase();
    String noteText = notes != null ? notes.trim() : "";

    if ("OLD_DUE".equals(type)) {
        double dueAmount = (amountStr != null && !amountStr.trim().isEmpty())
            ? Double.parseDouble(amountStr.trim()) : 0;
        if (dueAmount <= 0) {
            out.print("{\"success\":false,\"message\":\"Enter old due amount greater than zero.\"}");
            return;
        }
        double newBalance = bill.saveSupplierOldDue(supplierId, dueAmount, userId, noteText);
        out.print("{\"success\":true,\"entryType\":\"OLD_DUE\",\"newBalance\":" + newBalance + "}");
        return;
    }

    if ("COLLECTION".equals(type)) {
        Vector acc = bill.getSupplierAccount(supplierId);
        double accBal = 0;
        if (acc != null && acc.size() >= 4) {
            try { accBal = Double.parseDouble(acc.get(3).toString()); } catch (Exception ignore) {}
        }
        if (accBal <= 0) {
            out.print("{\"success\":false,\"message\":\"No account balance due to pay.\"}");
            return;
        }
        double cashPaid = (cashStr != null && !cashStr.trim().isEmpty()) ? Double.parseDouble(cashStr.trim()) : 0;
        double bankPaid = (bankStr != null && !bankStr.trim().isEmpty()) ? Double.parseDouble(bankStr.trim()) : 0;
        int payMode = Integer.parseInt(modeStr.trim());
        int payType = (typeStr != null && !typeStr.trim().isEmpty()) ? Integer.parseInt(typeStr.trim()) : 0;
        if (cashPaid + bankPaid <= 0) {
            out.print("{\"success\":false,\"message\":\"Payment amount must be greater than zero.\"}");
            return;
        }
        double newBalance = bill.saveSupplierAccountPayment(supplierId, cashPaid, bankPaid, payMode, payType, userId);
        out.print("{\"success\":true,\"entryType\":\"COLLECTION\",\"newBalance\":" + newBalance + "}");
        return;
    }

    if ("ADVANCE".equals(type)) {
        double cashPaid = (cashStr != null && !cashStr.trim().isEmpty()) ? Double.parseDouble(cashStr.trim()) : 0;
        double bankPaid = (bankStr != null && !bankStr.trim().isEmpty()) ? Double.parseDouble(bankStr.trim()) : 0;
        int payMode = (modeStr != null && !modeStr.trim().isEmpty()) ? Integer.parseInt(modeStr.trim()) : 1;
        int payType = (typeStr != null && !typeStr.trim().isEmpty()) ? Integer.parseInt(typeStr.trim()) : 0;
        if (cashPaid + bankPaid <= 0) {
            out.print("{\"success\":false,\"message\":\"Advance amount must be greater than zero.\"}");
            return;
        }
        double newAdvance = bill.saveSupplierAdvance(supplierId, cashPaid, bankPaid, payMode, payType, userId, noteText);
        out.print("{\"success\":true,\"entryType\":\"ADVANCE\",\"newAdvance\":" + newAdvance + "}");
        return;
    }

    out.print("{\"success\":false,\"message\":\"Invalid entry type.\"}");

} catch (NumberFormatException e) {
    out.print("{\"success\":false,\"message\":\"Invalid number format.\"}");
} catch (Exception e) {
    String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'") : "Save failed.";
    if (msg.toLowerCase().contains("txn_type") || msg.toLowerCase().contains("unknown column")) {
        msg = "Database update required. Please run database/supplier_account_setup.sql";
    }
    out.print("{\"success\":false,\"message\":\"" + msg + "\"}");
}
%>
