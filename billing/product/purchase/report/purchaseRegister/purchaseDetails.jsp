<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<%
String purchaseId = request.getParameter("id");
%>
<jsp:useBean id="prod" class="product.productBean" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
    <title>Purchase Details</title>
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        .pd-page { min-height: 100vh; background: var(--bill-bg, #f1f5f9); }
        .pd-header-grid .info-box {
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            padding: 8px 10px;
            background: #fff;
            height: 100%;
        }
        .pd-header-grid .form-label-sm {
            font-size: 0.72rem;
            margin-bottom: 2px;
            color: #64748b;
            text-transform: uppercase;
            letter-spacing: .3px;
        }
        .pd-table-wrap {
            overflow-x: auto;
            overflow-y: visible;
            -webkit-overflow-scrolling: touch;
            background: #fff;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
        }
        .pd-table-wrap table {
            min-width: 980px;
            margin-bottom: 0;
            font-size: 0.82rem;
        }
        .pd-table-wrap thead th {
            position: sticky;
            top: 0;
            background: #f8fafc;
            z-index: 2;
            white-space: nowrap;
        }
        .pd-footer-totals {
            display: flex;
            flex-wrap: wrap;
            gap: 8px 16px;
            justify-content: flex-end;
            align-items: center;
        }
        .pd-footer-totals .total-item {
            font-size: 0.85rem;
            color: #64748b;
        }
        .pd-footer-totals .total-item span {
            color: #0f172a;
            font-weight: 700;
        }
        .pd-footer-totals .grand-total {
            font-size: 1rem;
            width: 100%;
            text-align: right;
        }
        @media (min-width: 768px) {
            .pd-footer-totals .grand-total { width: auto; margin-left: 8px; }
        }
        @media (max-width: 767.98px) {
            .pd-table-wrap table { font-size: 0.78rem; }
            .pd-action-btns { display: flex; flex-direction: column; gap: 4px; min-width: 72px; }
            .pd-action-btns .btn { width: 100%; font-size: 0.72rem; padding: 2px 6px; }
            .pd-page { padding-bottom: calc(16px + env(safe-area-inset-bottom, 0px)); }
        }
    </style>
</head>
<body class="pd-page">
    <div class="container-fluid p-0 pb-3">
        <%@ include file="/assets/navbar/navbar.jsp" %>

        <%
        if (purchaseId != null && !purchaseId.isEmpty()) {
            try {
                // Get purchase header information
                Vector purchaseHeader = prod.getPurchaseHeaderById(Integer.parseInt(purchaseId));
                if (purchaseHeader != null && !purchaseHeader.isEmpty()) {
                    Vector header = (Vector) purchaseHeader.get(0);
        %>

        <!-- Top Section: Purchase Info -->
        <div class="card m-2 m-md-3 border-0 shadow-sm">
            <div class="card-body p-2 p-md-3">
                <div class="row g-2 pd-header-grid">
                    <div class="col-6 col-md-3">
                        <div class="info-box">
                            <label class="form-label-sm d-block">Invoice No</label>
                            <span class="fw-bold"><%= header.elementAt(1) %></span>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="info-box">
                            <label class="form-label-sm d-block">Invoice Date</label>
                            <span class="fw-bold"><%= header.elementAt(2) %></span>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="info-box">
                            <label class="form-label-sm d-block">Supplier</label>
                            <span class="fw-bold text-break"><%= header.elementAt(9) %></span>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="info-box">
                            <label class="form-label-sm d-block">Entry Date</label>
                            <span class="fw-bold"><%= header.elementAt(6) %> <%= header.elementAt(7) %></span>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="info-box">
                            <label class="form-label-sm d-block">Entered By</label>
                            <span class="fw-bold"><%= header.elementAt(8) %></span>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="info-box">
                            <label class="form-label-sm d-block">Total Amount</label>
                            <span class="fw-bold text-primary">₹<%= header.elementAt(3) %></span>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="info-box">
                            <label class="form-label-sm d-block">Paid Amount</label>
                            <span class="fw-bold text-success">₹<%= header.elementAt(4) %></span>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="info-box">
                            <label class="form-label-sm d-block">Balance</label>
                            <span class="fw-bold text-danger">₹<%= header.elementAt(5) %></span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Detail items -->
        <div class="px-2 px-md-3 mb-2">
            <div class="d-flex align-items-center justify-content-between mb-2">
                <h6 class="mb-0 fw-bold"><i class="fas fa-list me-1"></i> Purchase Items</h6>
                <small class="text-muted d-md-none">Swipe table → to see all columns</small>
            </div>
            <div class="pd-table-wrap">
            <table class="table table-bordered table-sm table-hover mb-0">
                <thead>
                    <tr>
                        <th style="width: 40px;">#</th>
                        <th>Product</th>
                        <th class="text-end d-none d-md-table-cell" style="width: 60px;">Pack</th>
                        <th class="text-end d-none d-lg-table-cell" style="width: 60px;">Qty/Pk</th>
                        <th class="text-end" style="width: 60px;">Qty</th>
                        <th class="text-end d-none d-md-table-cell" style="width: 60px;">Free</th>
                        <th class="text-end" style="width: 80px;">Rate</th>
                        <th class="text-end d-none d-lg-table-cell" style="width: 80px;">MRP</th>
                        <th class="text-end d-none d-lg-table-cell" style="width: 90px;">Total</th>
                        <th class="text-end d-none d-xl-table-cell" style="width: 60px;">GST%</th>
                        <th class="text-end d-none d-xl-table-cell" style="width: 80px;">CGST</th>
                        <th class="text-end d-none d-xl-table-cell" style="width: 80px;">SGST</th>
                        <th class="text-end" style="width: 90px;">Net</th>
                        <th style="width: 100px;">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    Vector purchaseDetails = prod.getPurchaseDetailsForEdit(Integer.parseInt(purchaseId));
                    double totalAmount = 0.0, totalCGST = 0.0, totalSGST = 0.0, grandTotal = 0.0;

                    if (purchaseDetails != null && !purchaseDetails.isEmpty()) {
                        for (int i = 0; i < purchaseDetails.size(); i++) {
                            Vector item = (Vector) purchaseDetails.get(i);
                            int    detId      = (Integer) item.elementAt(0);
                            String prodName   = (String)  item.elementAt(1);
                            double qty        = (Double)  item.elementAt(5);
                            double free       = (Double)  item.elementAt(6);
                            double rate       = (Double)  item.elementAt(7);
                            double mrp        = (Double)  item.elementAt(8);
                            double itemTotal  = (Double)  item.elementAt(9);
                            double tax        = (Double)  item.elementAt(10);
                            double cgst       = (Double)  item.elementAt(11);
                            double sgst       = (Double)  item.elementAt(12);
                            double netAmt     = (Double)  item.elementAt(13);
                            int    cancelled  = (Integer) item.elementAt(14);

                            if (cancelled == 0) { totalAmount += itemTotal; totalCGST += cgst; totalSGST += sgst; grandTotal += netAmt; }
                    %>
                    <tr class="<%= cancelled==1 ? "table-secondary text-decoration-line-through text-muted" : "" %>">
                        <td><%= i+1 %></td>
                        <td class="text-break"><%= prodName %> <% if (cancelled==1) { %><span class="badge bg-danger ms-1">Cancelled</span><% } %></td>
                        <td class="text-end d-none d-md-table-cell"><%= String.format("%.0f",(Double)item.elementAt(3)) %></td>
                        <td class="text-end d-none d-lg-table-cell"><%= String.format("%.3f",(Double)item.elementAt(4)) %></td>
                        <td class="text-end"><%= String.format("%.3f", qty) %></td>
                        <td class="text-end d-none d-md-table-cell"><%= String.format("%.3f", free) %></td>
                        <td class="text-end"><%= String.format("%.3f", rate) %></td>
                        <td class="text-end d-none d-lg-table-cell"><%= String.format("%.3f", mrp) %></td>
                        <td class="text-end d-none d-lg-table-cell"><%= String.format("%.3f", itemTotal) %></td>
                        <td class="text-end d-none d-xl-table-cell"><%= String.format("%.2f", tax) %></td>
                        <td class="text-end d-none d-xl-table-cell"><%= String.format("%.3f", cgst) %></td>
                        <td class="text-end d-none d-xl-table-cell"><%= String.format("%.3f", sgst) %></td>
                        <td class="text-end fw-bold"><%= String.format("%.3f", netAmt) %></td>
                        <td class="text-center">
                        <% if (cancelled == 0) { %>
                            <div class="pd-action-btns">
                            <button class="btn btn-outline-primary btn-sm py-0 px-1"
                                    onclick="openEditModal(<%= detId %>, '<%= purchaseId %>', '<%= prodName.replace("'","\\'"  ) %>', <%= rate %>, <%= mrp %>)"
                                    title="Edit Price"><i class="fas fa-edit"></i><span class="d-none d-md-inline"> Edit</span></button>
                            <button class="btn btn-outline-danger btn-sm py-0 px-1"
                                    onclick="cancelItem(<%= detId %>, '<%= purchaseId %>', '<%= prodName.replace("'","\\'"  ) %>')"
                                    title="Cancel Item"><i class="fas fa-ban"></i><span class="d-none d-md-inline"> Cancel</span></button>
                            </div>
                        <% } %>
                        </td>
                    </tr>
                    <%
                        }
                    } else {
                    %>
                    <tr>
                        <td colspan="14" class="text-center py-3">No items found for this purchase.</td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
            </div>
        </div>

        <!-- Bottom Section: Footer Totals -->
        <div class="card mx-2 mx-md-3 mb-3 border-0 shadow-sm">
            <div class="card-body p-2 p-md-3">
                <div class="d-flex flex-column flex-md-row align-items-stretch align-items-md-center gap-3">
                    <div class="d-flex flex-wrap gap-2">
                        <a href="page.jsp" class="btn btn-secondary btn-sm">
                            <i class="fas fa-arrow-left me-1"></i> Back
                        </a>
                        <a href="<%=contextPath%>/product/purchase/purchaseReturn/page.jsp?purchaseId=<%= purchaseId %>" class="btn btn-warning btn-sm">
                            <i class="fas fa-undo me-1"></i> Return
                        </a>
                    </div>
                    <div class="pd-footer-totals flex-grow-1">
                        <div class="total-item">Sub Total: <span>₹<%= String.format("%.3f", totalAmount) %></span></div>
                        <div class="total-item">CGST: <span>₹<%= String.format("%.3f", totalCGST) %></span></div>
                        <div class="total-item">SGST: <span>₹<%= String.format("%.3f", totalSGST) %></span></div>
                        <div class="total-item grand-total">Grand Total: <span class="text-primary fs-5">₹<%= String.format("%.3f", grandTotal) %></span></div>
                    </div>
                </div>
            </div>
        </div>

        <%
                } else {
        %>
        <div class="container mt-5">
            <div class="alert alert-warning shadow-sm">
                <i class="fas fa-exclamation-triangle me-2"></i> Purchase not found.
                <a href="page.jsp" class="alert-link ms-2">Go Back</a>
            </div>
        </div>
        <%
                }
            } catch (Exception e) {
                e.printStackTrace();
        %>
        <div class="container mt-5">
            <div class="alert alert-danger shadow-sm">
                <h5 class="alert-heading"><i class="fas fa-exclamation-circle me-2"></i>Error loading details</h5>
                <p class="mb-0"><%= e.getMessage() %></p>
                <hr>
                <p class="mb-0 small">Purchase ID: <%= purchaseId %></p>
                <a href="page.jsp" class="btn btn-outline-danger btn-sm mt-2">Go Back</a>
            </div>
        </div>
        <%
            }
        } else {
        %>
        <div class="container mt-5">
            <div class="alert alert-warning shadow-sm">
                <i class="fas fa-exclamation-triangle me-2"></i> Invalid purchase ID.
                <a href="page.jsp" class="alert-link ms-2">Go Back</a>
            </div>
        </div>
        <%
        }
        %>
    </div>

<!-- ── Edit Price Modal ─────────────────────────────── -->
<div class="modal fade" id="editPriceModal" tabindex="-1">
  <div class="modal-dialog modal-sm">
    <div class="modal-content">
      <div class="modal-header py-2">
        <h6 class="modal-title"><i class="fas fa-edit me-1"></i> Edit Price</h6>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <p class="mb-2 fw-semibold" id="editProdName"></p>
        <div class="mb-2">
          <label class="form-label form-label-sm mb-0">Rate (Cost)</label>
          <input type="number" step="0.001" min="0.001" id="editRate" class="form-control form-control-sm">
        </div>
        <div class="mb-2">
          <label class="form-label form-label-sm mb-0">MRP</label>
          <input type="number" step="0.001" min="0.001" id="editMrp" class="form-control form-control-sm">
        </div>
        <div class="mb-2">
          <label class="form-label form-label-sm mb-0">Reason</label>
          <input type="text" id="editReason" class="form-control form-control-sm" placeholder="optional">
        </div>
      </div>
      <div class="modal-footer py-1">
        <button class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
        <button class="btn btn-primary btn-sm" onclick="submitEditPrice()">Save</button>
      </div>
    </div>
  </div>
</div>

<script>
const CTX = '<%=contextPath%>';
let _editDetailId = 0, _editPurchaseId = 0;

function openEditModal(detailId, purchaseId, prodName, rate, mrp) {
    _editDetailId   = detailId;
    _editPurchaseId = purchaseId;
    document.getElementById('editProdName').textContent = prodName;
    document.getElementById('editRate').value   = rate;
    document.getElementById('editMrp').value    = mrp;
    document.getElementById('editReason').value = '';
    new bootstrap.Modal(document.getElementById('editPriceModal')).show();
}

function submitEditPrice() {
    const rate   = parseFloat(document.getElementById('editRate').value);
    const mrp    = parseFloat(document.getElementById('editMrp').value);
    const reason = document.getElementById('editReason').value.trim();
    if (!rate || rate <= 0 || !mrp || mrp <= 0) {
        Swal.fire('Validation', 'Rate and MRP must be greater than 0.', 'warning');
        return;
    }
    bootstrap.Modal.getInstance(document.getElementById('editPriceModal')).hide();
    $.ajax({
        url: CTX + '/product/purchase/editPurchaseItemPrice.jsp',
        method: 'POST',
        data: { detailId: _editDetailId, purchaseId: _editPurchaseId, newRate: rate, newMrp: mrp, reason: reason },
        success: function(res) {
            if (res.success) {
                Swal.fire({ icon:'success', title:'Updated', text: res.message, timer:1800, showConfirmButton:false })
                    .then(() => location.reload());
            } else {
                Swal.fire('Error', res.message, 'error');
            }
        },
        error: function() { Swal.fire('Error', 'Server error.', 'error'); }
    });
}

function cancelItem(detailId, purchaseId, prodName) {
    Swal.fire({
        title: 'Cancel Item?',
        html: '<b>' + prodName + '</b><br><small class="text-muted">Stock will be reduced. This cannot be undone.</small>' +
              '<br><br><input type="text" id="cancelReason" class="form-control form-control-sm" placeholder="Reason (optional)">',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#dc3545',
        confirmButtonText: 'Yes, Cancel It',
        cancelButtonText: 'Back',
        preConfirm: () => document.getElementById('cancelReason').value
    }).then(result => {
        if (!result.isConfirmed) return;
        $.ajax({
            url: CTX + '/product/purchase/cancelPurchaseItem.jsp',
            method: 'POST',
            data: { detailId: detailId, purchaseId: purchaseId, reason: result.value },
            success: function(res) {
                if (res.success) {
                    Swal.fire({ icon:'success', title:'Cancelled', text: res.message, timer:1800, showConfirmButton:false })
                        .then(() => location.reload());
                } else {
                    Swal.fire('Error', res.message, 'error');
                }
            },
            error: function() { Swal.fire('Error', 'Server error.', 'error'); }
        });
    });
}
</script>
</body>
</html>