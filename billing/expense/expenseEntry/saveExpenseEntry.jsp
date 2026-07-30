<%@page language="java" import="java.util.*" %>
<jsp:useBean id="prod" class="product.productBean" />

<%
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}

String expenseTypeParam = request.getParameter("expenseType");
String content = request.getParameter("content");
String description = request.getParameter("description");
String amountParam = request.getParameter("amount");
String expenseDate = request.getParameter("expenseDate");
String expenseTime = request.getParameter("expenseTime");
String payModeParam = request.getParameter("payMode");
String payTypeParam = request.getParameter("payType");
String cashPaidParam = request.getParameter("cashPaid");
String bankPaidParam = request.getParameter("bankPaid");
String balanceParam = request.getParameter("balance");

try {
    int expenseType = Integer.parseInt(expenseTypeParam);
    double amount = Double.parseDouble(amountParam);
    int payMode = (payModeParam != null && !payModeParam.trim().isEmpty()) ? Integer.parseInt(payModeParam) : 1;
    int payType = (payTypeParam != null && !payTypeParam.trim().isEmpty()) ? Integer.parseInt(payTypeParam) : 0;
    double cashPaid = (cashPaidParam != null && !cashPaidParam.trim().isEmpty()) ? Double.parseDouble(cashPaidParam) : 0;
    double bankPaid = (bankPaidParam != null && !bankPaidParam.trim().isEmpty()) ? Double.parseDouble(bankPaidParam) : 0;
    double balance = (balanceParam != null && !balanceParam.trim().isEmpty()) ? Double.parseDouble(balanceParam) : 0;

    if (amount <= 0) throw new Exception("Please enter a valid amount.");
    if (Math.abs((cashPaid + bankPaid + balance) - amount) > 0.01) {
        throw new Exception("Cash + Bank + Balance must equal the expense amount.");
    }
    if (payMode == 1 && cashPaid <= 0 && balance <= 0) {
        throw new Exception("Please enter cash paid amount.");
    }
    if (payMode == 2 && bankPaid <= 0 && balance <= 0) {
        throw new Exception("Please enter bank paid amount.");
    }

    String expenseDateTime = expenseDate + " " + expenseTime + ":00";

    prod.addExpenseEntry(expenseType, content, description, amount, expenseDateTime,
            payMode, payType, cashPaid, bankPaid, userId);

    response.sendRedirect(request.getContextPath() + "/expense/expenseEntry/page.jsp?msg=Expense+entry+added+successfully!&type=success");
} catch (Exception e) {
    response.sendRedirect(
        "page.jsp?msg=Error+occurred+while+saving+expense:+"
        + java.net.URLEncoder.encode(e.getMessage(), "UTF-8")
        + "&type=danger"
    );
}
%>
