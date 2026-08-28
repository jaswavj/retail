<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:useBean id="bill" class="billing.salesReturnBean" />
<jsp:useBean id="prod" class="product.productBean" />
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    if (session.getAttribute("userId") == null) {
        out.print("{\"success\":false,\"message\":\"Not authenticated\"}");
        return;
    }

    try {
        int billId     = Integer.parseInt(request.getParameter("billId"));
        int customerId = Integer.parseInt(request.getParameter("customerId"));
        String cusName = request.getParameter("cusName");
        String cusPhn  = request.getParameter("cusPhn");
        if (cusPhn == null) cusPhn = "";

        boolean isNewCustomer = false;
        if (customerId <= 0) {
            if (cusName == null || cusName.trim().isEmpty()) {
                out.print("{\"success\":false,\"message\":\"Customer name is required.\"}");
                return;
            }
            int existingId = prod.checkTheCustomerNameExist(cusName.trim());
            if (existingId > 0) {
                customerId = existingId;
            } else {
                customerId = prod.addCustomerReturnId(cusName.trim(), cusPhn.trim());
                isNewCustomer = true;
            }
        }

        String msg = bill.updateBillCustomer(billId, customerId, cusName, cusPhn);
        if (isNewCustomer) {
            msg = "New customer created and assigned to bill.";
        }
        out.print("{\"success\":true,\"message\":\"" + msg.replace("\"","'") + "\",\"customerId\":" + customerId
                + ",\"cusName\":\"" + (cusName != null ? cusName.replace("\"","'").replace("\\","\\\\") : "") + "\""
                + ",\"cusPhn\":\"" + (cusPhn != null ? cusPhn.replace("\"","'").replace("\\","\\\\") : "") + "\""
                + ",\"isNewCustomer\":" + isNewCustomer + "}");
    } catch (Exception e) {
        out.print("{\"success\":false,\"message\":\"" + e.getMessage().replace("\"","'") + "\"}");
    }
%>
