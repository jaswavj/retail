<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, org.json.*"%>
<jsp:useBean id="billing" class="billing.billingBean" />
<%
response.setContentType("application/json;charset=UTF-8");
Integer uid = (Integer) session.getAttribute("userId");
if (uid == null) {
    out.print("[]");
    return;
}

JSONArray arr = new JSONArray();
try {
    Vector list = billing.getDayBookOpeningBalanceList();
    for (int i = 0; i < list.size(); i++) {
        Vector row = (Vector) list.get(i);
        JSONObject obj = new JSONObject();
        obj.put("id", row.get(0).toString());
        obj.put("balanceDate", row.get(1).toString());
        obj.put("amount", row.get(2).toString());
        obj.put("notes", row.get(3).toString());
        obj.put("userName", row.get(4).toString());
        obj.put("entryDate", row.get(5).toString());
        obj.put("entryTime", row.get(6).toString());
        int payMode = 1;
        double cashPaid = 0, bankPaid = 0;
        try { payMode = Integer.parseInt(row.get(7).toString()); } catch (Exception ignore) {}
        try { cashPaid = Double.parseDouble(row.get(8).toString()); } catch (Exception ignore) {}
        try { bankPaid = Double.parseDouble(row.get(9).toString()); } catch (Exception ignore) {}
        obj.put("payMode", payMode);
        obj.put("cashPaid", cashPaid);
        obj.put("bankPaid", bankPaid);
        String payLabel;
        if (cashPaid > 0.005 && bankPaid > 0.005) {
            payLabel = "Mixed";
        } else if (bankPaid > 0.005 || payMode == 2) {
            payLabel = "Bank";
        } else {
            payLabel = "Cash";
        }
        obj.put("payLabel", payLabel);
        arr.put(obj);
    }
} catch (Exception e) {
    // table may not exist yet
}
out.print(arr.toString());
%>
