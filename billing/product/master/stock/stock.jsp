<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%@ page errorPage="" %>
<jsp:useBean id="prod" class="product.productBean" />
<%
// Session check
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>STOCK - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <!-- Bootstrap CSS -->
    <%@ include file="/assets/common/head.jsp" %>

    <style>
        body {
            background: #f5f7fa;
        }
        .table td, .table th {
            vertical-align: middle;
        }
    </style>

    <script>
$(function () {
    $("#catName").autocomplete({
        source: function (request, response) {
            $.ajax({
                url: "auto_complet.jsp",
                type: "GET",
                data: { productSearch: request.term },
                success: function (data) {
                    response($.parseJSON(data));
                    
                }
            });
        },
        minLength: 2,
        select: function (event, ui) {
            // ui.item.label = name, ui.item.value = id
            $("#catName").val(ui.item.label);
            $("#catId").val(ui.item.value); 
            return false;
        }
    });
});

$(document).ready(function(){
    // Product search functionality
    document.getElementById('searchInput').addEventListener('input', function() {
        const searchTerm = this.value.toLowerCase();
        const tableRows = document.querySelectorAll('#productTable tbody tr');
        
        tableRows.forEach(row => {
            // Skip the "no products found" row
            if (row.cells.length === 1 && row.cells[0].colSpan === 5) {
                return;
            }
            
            const productName = row.cells[1].textContent.toLowerCase();
            const productCode = row.cells[2].textContent.toLowerCase();
            const category = row.cells[3].textContent.toLowerCase();
            const brand = row.cells[4].textContent.toLowerCase();
            
            if (productName.includes(searchTerm) || 
                productCode.includes(searchTerm) || 
                category.includes(searchTerm) || 
                brand.includes(searchTerm)) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    });
});
</script>


</head>
<body>

    <%@ include file="/assets/navbar/navbar.jsp" %>
    <!-- Top Navbar -->


    <div class="container-fluid mt-2" style="max-width: 1400px;">
        <div class="row g-2">
            <!-- Left Column - Search Product -->
            <div class="col-md-4">
                <div class="card" style="border: none; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.07); border-radius: 8px; height: 100%;">
                    <div class="card-header" style="background: var(--page-header-card-bg); color: white; border-radius: 8px 8px 0 0; padding: 0.75rem 1rem;">
                        <h6 class="mb-0" style="font-weight: 600; font-size: 0.95rem;"><i class="fas fa-search me-2"></i>Search <%=head3%></h6>
                    </div>
                    <div class="card-body" style="padding: 1rem;">
                        <form action="<%=contextPath%>/product/master/stock/stock1.jsp" method="post">
                            <input type="hidden" id="catId" name="catId">
                            <div class="mb-3">
                                <div class="input-outline">
                                    <input type="text" id="catName" name="catName" class="form-control" placeholder="" style="padding: 8px 10px; border: 2px solid #e2e8f0; border-radius: 6px; font-size: 0.9rem;" required>
                                    <label style="background: white; padding: 0 6px; font-size: 0.85rem;">Search <%=head3%></label>
                                </div>
                                <small class="text-muted" style="font-size: 0.75rem; display: block; margin-top: 4px;">Type at least 2 characters to search</small>
                            </div>
                            
                            <button type="submit" class="btn btn-primary w-100" style="padding: 8px 10px; font-size: 0.9rem;">
                                <i class="fas fa-search me-1"></i>Search
                            </button>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Right Column - Product List -->
            <div class="col-md-8">
                <div class="card" style="border: none; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.07); border-radius: 8px;">
                    <div class="card-header" style="background: white; border-bottom: 1px solid #f7fafc; border-radius: 8px 8px 0 0; padding: 0.75rem 1rem;">
                        <div class="d-flex justify-content-between align-items-center">
                            <h6 class="mb-0" style="color: #2d3748; font-weight: 600; font-size: 0.95rem;"><i class="fas fa-list me-2"></i><%=head3%> List</h6>
                            <div class="input-group" style="width: 300px;">
                                <span class="input-group-text" style="background: #f8f9fa; border: 1px solid #dee2e6;"><i class="fas fa-search"></i></span>
                                <input type="text" id="searchInput" class="form-control" placeholder="Search products..." style="border-left: none; font-size: 0.85rem;">
                            </div>
                        </div>
                    </div>
                    <div class="card-body" style="padding: 0; max-height: 600px; overflow-y: auto; overflow-x: auto;">
                        <div class="table-responsive">
                        <table id="productTable" class="table table-hover mb-0" style="border-collapse: separate; border-spacing: 0; font-size: 0.85rem; table-layout: fixed; width: 100%; min-width: 600px;">
                            <thead style="background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%); position: sticky; top: 0; z-index: 10;">
                                <tr>
                                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.8rem; width: 5%;">#</th>
                                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.8rem; width: 25%;"><i class="fas fa-box me-1"></i>Name</th>
                                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.8rem; width: 15%;">Code</th>
                                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.8rem; width: 15%;"><%=head1%></th>
                                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.8rem; width: 15%;"><%=head2%></th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                try {
                                    Vector productList = prod.getAllProductsReverse();
                                    if (productList != null && productList.size() > 0) {
                                        for (int i = 0; i < productList.size(); i++) {
                                            Vector row = (Vector) productList.get(i);
                                            if (row != null && row.size() > 4) {
                                                String productName = row.elementAt(0).toString();
                                                String categoryName = row.elementAt(1).toString();
                                                String brandName = row.elementAt(2).toString();
                                                int productId = Integer.parseInt(row.elementAt(3).toString());
                                                String prodCode = row.elementAt(4).toString();
                                %>
                                <tr style="border-bottom: 1px solid #f1f5f9; transition: all 0.2s;">
                                    <td style="padding: 0.4rem; color: #718096; border: none; width: 5%;"><%=i+1%></td>
                                    <td style="padding: 0.4rem; color: #2d3748; font-weight: 500; border: none; width: 25%; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="<%=productName%>"><%=productName%></td>
                                    <td style="padding: 0.4rem; color: #718096; border: none; width: 15%;"><%=prodCode%></td>
                                    <td style="padding: 0.4rem; color: #718096; border: none; width: 15%;"><%=categoryName%></td>
                                    <td style="padding: 0.4rem; color: #718096; border: none; width: 15%;"><%=brandName%></td>
                                </tr>
                                <%
                                            }
                                        }
                                    } else {
                                %>
                                <tr>
                                    <td colspan="5" class="text-center" style="padding: 2rem; color: #718096; font-size: 0.85rem;">
                                        <i class="fas fa-inbox fa-3x mb-3" style="opacity: 0.3;"></i>
                                        <p class="mb-0">No products found.</p>
                                    </td>
                                </tr>
                                <%
                                    }
                                } catch (Exception e) {
                                    out.println("<tr><td colspan='5' class='text-center text-danger' style='font-size: 0.85rem;'>Error loading products: " + e.getMessage() + "</td></tr>");
                                    e.printStackTrace();
                                }
                                %>
                            </tbody>
                        </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <!-- Bootstrap JS -->
</body>
</html>
