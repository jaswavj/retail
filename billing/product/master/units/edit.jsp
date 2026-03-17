<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Edit Unit - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        body { background: #f5f7fa; }
        .navbar { background-color: #4e73df; }
        .navbar-brand { color: #fff !important; }
    </style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="container mt-4">
        <h3>Edit Unit</h3>
        
        <div class="card">
            <div class="card-body">
                <%
                    String idStr = request.getParameter("id");
                    String name = request.getParameter("name");
                    String isActiveStr = request.getParameter("isActive");
                    
                    if (idStr != null && name != null) {
                        int id = Integer.parseInt(idStr);
                        int isActive = Integer.parseInt(isActiveStr);
                %>
                
                <form action="<%=contextPath%>/product/master/units/update.jsp" method="post" class="row g-3">
                    <input type="hidden" name="id" value="<%=id%>">
                    
                    <div class="col-md-8 input-outline">
                        <input type="text" name="unitName" class="form-control" value="<%=name%>" placeholder="" required>
                        <label>Unit Name</label>
                    </div>
                    
                    <div class="col-md-12">
                        <button type="submit" class="btn btn-primary">Update Unit</button>
                        <a href="<%=contextPath%>/product/master/units/page.jsp" class="btn btn-secondary">Cancel</a>
                    </div>
                </form>
                
                <% } else { %>
                    <div class="alert alert-danger">Invalid unit information provided.</div>
                <% } %>
            </div>
        </div>
    </div>

    <script>
      document.addEventListener('contextmenu', function (e) {
        e.preventDefault();
      });
    </script>
</body>
</html>
