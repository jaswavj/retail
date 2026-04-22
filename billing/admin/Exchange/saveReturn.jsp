<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    Integer uid = (Integer) session.getAttribute("userId");
    if (uid == null) {
        out.print("{\"success\":false,\"message\":\"Not authenticated\"}");
        return;
    }

    String billNo    = request.getParameter("billNo");
    String detailIdS = request.getParameter("detailId");

    if (billNo == null || billNo.trim().isEmpty()
        || detailIdS == null || detailIdS.trim().isEmpty()) {
        out.print("{\"success\":false,\"message\":\"Missing required parameters\"}");
        return;
    }

    try {
        billNo         = billNo.trim();
        int detailId   = Integer.parseInt(detailIdS.trim());

        String resultMsg = bill.saveReturn(billNo, detailId, uid);
        out.print("{\"success\":true,\"message\":\"" + resultMsg.replace("\"","'") + "\"}");

    } catch (NumberFormatException e) {
        out.print("{\"success\":false,\"message\":\"Invalid detail ID\"}");
    } catch (Exception e) {
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"","'") : "Server error";
        out.print("{\"success\":false,\"message\":\"" + msg + "\"}");
    }
%>
