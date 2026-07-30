<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:useBean id="billing" class="billing.billingBean" />
<%
response.setContentType("application/json;charset=UTF-8");
Integer uid = (Integer) session.getAttribute("userId");
if (uid == null) {
    out.print("{\"success\":false,\"message\":\"Session expired. Please login again.\"}");
    return;
}

try {
    String balanceDate = request.getParameter("balanceDate");
    String amountStr   = request.getParameter("amount");
    String notes       = request.getParameter("notes");
    String payModeStr  = request.getParameter("payMode");
    String payTypeStr  = request.getParameter("payType");
    String cashStr     = request.getParameter("cashPaid");
    String bankStr     = request.getParameter("bankPaid");

    if (balanceDate == null || balanceDate.trim().isEmpty()) {
        out.print("{\"success\":false,\"message\":\"Date is required.\"}");
        return;
    }
    if (amountStr == null || amountStr.trim().isEmpty()) {
        out.print("{\"success\":false,\"message\":\"Amount is required.\"}");
        return;
    }

    double amount   = Double.parseDouble(amountStr.trim());
    int payMode     = (payModeStr != null && !payModeStr.trim().isEmpty()) ? Integer.parseInt(payModeStr.trim()) : 1;
    int payType     = (payTypeStr != null && !payTypeStr.trim().isEmpty()) ? Integer.parseInt(payTypeStr.trim()) : 0;
    double cashPaid = (cashStr != null && !cashStr.trim().isEmpty()) ? Double.parseDouble(cashStr.trim()) : 0;
    double bankPaid = (bankStr != null && !bankStr.trim().isEmpty()) ? Double.parseDouble(bankStr.trim()) : 0;

    if (amount <= 0) {
        out.print("{\"success\":false,\"message\":\"Amount must be greater than zero.\"}");
        return;
    }
    if (Math.abs((cashPaid + bankPaid) - amount) > 0.01) {
        out.print("{\"success\":false,\"message\":\"Cash + Bank must equal the amount.\"}");
        return;
    }
    if (payMode == 1 && cashPaid <= 0) {
        out.print("{\"success\":false,\"message\":\"Please enter cash paid amount.\"}");
        return;
    }
    if (payMode == 2 && bankPaid <= 0) {
        out.print("{\"success\":false,\"message\":\"Please enter bank paid amount.\"}");
        return;
    }

    int newId = billing.saveDayBookOpeningBalance(balanceDate.trim(), amount,
            notes != null ? notes.trim() : "", payMode, payType, cashPaid, bankPaid, uid);
    out.print("{\"success\":true,\"message\":\"Opening balance saved successfully.\",\"id\":" + newId + "}");
} catch (NumberFormatException e) {
    out.print("{\"success\":false,\"message\":\"Invalid number format.\"}");
} catch (Exception e) {
    e.printStackTrace();
    String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'").replace("\\", "/") : "Save failed.";
    if (msg.toLowerCase().contains("daybook_opening_balance") || msg.toLowerCase().contains("doesn't exist")) {
        msg = "Table not found. Please run database/daybook_opening_balance_setup.sql first.";
    }
    out.print("{\"success\":false,\"message\":\"" + msg + "\"}");
}
%>
