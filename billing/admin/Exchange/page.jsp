<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    Integer uid = (Integer) session.getAttribute("userId");
    if (uid == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    String contextPathExc = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Exchange - Admin</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        .exchange-badge {
            font-size: 0.7rem;
            background: #dc3545;
            color: #fff;
            padding: 2px 7px;
            border-radius: 20px;
        }
        .exchanged-row td { background: #f8f0ff !important; }
        .returned-row td  { background: #fff3cd !important; }
        .return-badge {
            font-size: 0.7rem;
            background: #fd7e14;
            color: #fff;
            padding: 2px 7px;
            border-radius: 20px;
        }
        .prod-search-input { position: relative; }
        .autocomplete-list {
            position: absolute;
            z-index: 9999;
            background: var(--bill-card);
            border: 1px solid #ccc;
            border-top: none;
            width: 100%;
            max-height: 200px;
            overflow-y: auto;
            list-style: none;
            padding: 0;
            margin: 0;
            box-shadow: 0 4px 8px rgba(0,0,0,.1);
        }
        .autocomplete-list li {
            padding: 8px 12px;
            cursor: pointer;
            font-size: 0.9rem;
        }
        .autocomplete-list li:hover, .autocomplete-list li.active {
            background: var(--bill-navy);
            color: #fff;
        }
        .cust-search-input { position: relative; }
        .customer-pending-banner {
            background: #fff3cd;
            border: 1px solid #ffc107;
            border-radius: 6px;
            padding: 10px 14px;
            font-size: 0.9rem;
            color: #856404;
        }
    </style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "Product Exchange");
    request.setAttribute("pageSubtitle", "Admin — Exchange");
    request.setAttribute("pageIcon",     "fa-solid fa-arrow-right-arrow-left");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container-fluid mt-3 mst-page">

        <div class="card mst-card mb-4">
            <div class="card-body">
                <div class="row g-2 align-items-end">
                    <div class="col-md-4">
                        <label class="form-label fw-semibold">Bill Number</label>
                        <div class="input-group">
                            <input type="text" id="billNoInput" class="form-control fg-inp" placeholder="Enter bill number…" autofocus>
                            <button class="bb bb-primary" id="searchBillBtn">
                                <i class="fa-solid fa-magnifying-glass"></i> Load
                            </button>
                        </div>
                    </div>
                    <div class="col-md-8" id="billSummaryArea"></div>
                </div>
            </div>
        </div>

        <!-- Bill Items Table -->
        <div id="billItemsArea" class="d-none">
            <div class="card mst-card">
                <div class="mst-card-header d-flex justify-content-between align-items-center">
                    <span class="fw-semibold">Bill Items</span>
                    <span class="text-muted small" id="billNoDisplay"></span>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table mst-table mb-0" id="billTable">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Product</th>
                                    <th>Qty</th>
                                    <th>Price</th>
                                    <th>Disc</th>
                                    <th>Total</th>
                                    <th>Status</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody id="billItemsTbody"></tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Customer Update Modal (required when bill customerId = 1) -->
    <div class="modal fade" id="customerUpdateModal" tabindex="-1" data-bs-backdrop="static" data-bs-keyboard="false" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header mst-card-header">
                    <h5 class="modal-title"><i class="fa-solid fa-user-pen me-2"></i>Assign Customer</h5>
                </div>
                <div class="modal-body">
                    <div class="alert alert-warning py-2 mb-3">
                        <i class="fa-solid fa-circle-info me-1"></i>
                        This bill has no customer assigned. Select an existing customer from the list, or type a new name and phone to create one.
                    </div>
                    <div class="mb-3 cust-search-input">
                        <label class="form-label fw-semibold">Customer Name <span class="text-danger">*</span></label>
                        <input type="text" id="custNameInput" class="form-control fg-inp" placeholder="Type customer name…" autocomplete="off">
                        <ul class="autocomplete-list d-none" id="custNameList"></ul>
                    </div>
                    <div class="mb-3 cust-search-input">
                        <label class="form-label fw-semibold">Phone Number</label>
                        <input type="text" id="custPhoneInput" class="form-control fg-inp" placeholder="Type phone number…" autocomplete="off">
                        <ul class="autocomplete-list d-none" id="custPhoneList"></ul>
                    </div>
                    <input type="hidden" id="custIdInput" value="">
                </div>
                <div class="modal-footer">
                    <button type="button" class="bb bb-primary" id="confirmCustomerBtn">
                        <i class="fa-solid fa-check me-1"></i>Update &amp; Continue
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Exchange Modal -->
    <div class="modal fade" id="exchangeModal" tabindex="-1" aria-labelledby="exchangeModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header mst-card-header">
                    <h5 class="modal-title" id="exchangeModalLabel"><i class="fa-solid fa-right-left me-2"></i>Exchange Item</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3 p-3 rounded" style="background:var(--bill-bg)">
                        <div class="text-muted small mb-1">Replacing:</div>
                        <div class="fw-semibold" id="oldProductName">-</div>
                        <div class="d-flex gap-3 mt-1">
                            <span class="small">Qty: <strong id="oldQty">-</strong></span>
                            <span class="small">Price: ₹<strong id="oldPrice">-</strong></span>
                            <span class="small">Total: ₹<strong id="oldTotal">-</strong></span>
                        </div>
                    </div>

                    <div class="mb-3 prod-search-input">
                        <label class="form-label fw-semibold">New Product <span class="text-danger">*</span></label>
                        <input type="text" id="newProdSearch" class="form-control fg-inp" placeholder="Type product name to search…" autocomplete="off">
                        <ul class="autocomplete-list d-none" id="prodAutocompleteList"></ul>
                        <input type="hidden" id="newProdId" value="">
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-semibold">New Price (₹) <span class="text-danger">*</span></label>
                        <input type="number" id="newPrice" class="form-control fg-inp" min="0" step="0.01" placeholder="Enter price">
                        <div class="form-text" id="priceDiffHint"></div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="bb bb-outline" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="bb bb-primary" id="confirmExchangeBtn">
                        <i class="fa-solid fa-check me-1"></i>Confirm Exchange
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script>
    const CTX = '<%=contextPathExc%>';
    let currentBillData = null;  // { billId, customerId, items[] }
    let customerUpdateRequired = false;
    let currentDetailId = null;
    let currentOldTotal = 0;
    let currentQty = 0;

    // ── Load bill ─────────────────────────────────────────────
    document.getElementById('searchBillBtn').addEventListener('click', loadBill);
    document.getElementById('billNoInput').addEventListener('keydown', function(e) {
        if (e.key === 'Enter') loadBill();
    });

    function loadBill() {
        const billNo = document.getElementById('billNoInput').value.trim();
        if (!billNo) return;

        fetch(CTX + '/admin/Exchange/getBillForExchange.jsp?billNo=' + encodeURIComponent(billNo))
            .then(r => r.json())
            .then(data => {
                if (!data.success) {
                    Swal.fire('Not Found', data.message || 'Bill not found.', 'error');
                    return;
                }
                currentBillData = data;
                customerUpdateRequired = (parseInt(data.customerId) === 1);
                renderBill(data);
                if (customerUpdateRequired) {
                    openCustomerUpdateModal();
                }
            })
            .catch(() => Swal.fire('Error', 'Failed to load bill.', 'error'));
    }

    function renderBill(data) {
        // Summary
        let summaryHtml = `
            <div class="d-flex flex-wrap gap-3 align-items-center">
                <span class="badge bg-secondary fs-6">Customer: ${escHtml(data.cusName)}</span>
                <span class="badge bg-info text-dark fs-6">Total: ₹${data.total}</span>
                <span class="badge bg-success fs-6">Payable: ₹${data.payable}</span>
                <span class="badge bg-warning text-dark fs-6">Date: ${escHtml(data.billDate)}</span>
            </div>`;
        if (customerUpdateRequired) {
            summaryHtml += `<div class="customer-pending-banner mt-2"><i class="fa-solid fa-triangle-exclamation me-1"></i> Customer not assigned — please update customer to proceed with exchange or return.</div>`;
        }
        document.getElementById('billSummaryArea').innerHTML = summaryHtml;
        document.getElementById('billNoDisplay').textContent = 'Bill #' + data.billNo;

        const tbody = document.getElementById('billItemsTbody');
        tbody.innerHTML = '';
        data.items.forEach((item, idx) => {
            const exchanged = item.isExchanged == 1;
            const returned  = item.isExchanged == 2;
            const tr = document.createElement('tr');
            if (exchanged) tr.classList.add('exchanged-row');
            if (returned)  tr.classList.add('returned-row');

            let statusBadge;
            if (exchanged) statusBadge = '<span class="exchange-badge">Exchanged</span>';
            else if (returned) statusBadge = '<span class="return-badge">Returned</span>';
            else statusBadge = '<span class="badge bg-success">Active</span>';

            let actionBtns;
            if (exchanged || returned) {
                actionBtns = `<button class="btn btn-sm btn-outline-secondary" disabled><i class="fa-solid fa-ban me-1"></i>${exchanged ? 'Exchanged' : 'Returned'}</button>`;
            } else {
                const disabled = customerUpdateRequired ? 'disabled title="Assign customer first"' : '';
                actionBtns = `
                    <button class="btn btn-sm btn-outline-warning open-return-btn" ${disabled}
                        data-detail-id="${item.detailId}"
                        data-prod-name="${escHtml(item.productName)}"
                        data-qty="${item.qty}"
                        data-total="${item.total}">
                        <i class="fa-solid fa-rotate-left me-1"></i>Return
                    </button>`;
            }

            tr.innerHTML = `
                <td>${idx + 1}</td>
                <td>${escHtml(item.productName)}</td>
                <td>${item.qty}</td>
                <td>₹${item.price}</td>
                <td>₹${item.disc}</td>
                <td>₹${item.total}</td>
                <td>${statusBadge}</td>
                <td>${actionBtns}</td>`;
            tbody.appendChild(tr);
        });

        document.getElementById('billItemsArea').classList.remove('d-none');
        attachExchangeButtons();
        attachReturnButtons();
    }

    function attachExchangeButtons() {
        document.querySelectorAll('.open-exchange-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                currentDetailId = this.dataset.detailId;
                currentOldTotal = parseFloat(this.dataset.total);
                currentQty = parseFloat(this.dataset.qty);

                document.getElementById('oldProductName').textContent = this.dataset.prodName;
                document.getElementById('oldQty').textContent = this.dataset.qty;
                document.getElementById('oldPrice').textContent = this.dataset.price;
                document.getElementById('oldTotal').textContent = this.dataset.total;

                document.getElementById('newProdSearch').value = '';
                document.getElementById('newProdId').value = '';
                document.getElementById('newPrice').value = '';
                document.getElementById('priceDiffHint').textContent = '';
                document.getElementById('prodAutocompleteList').innerHTML = '';
                document.getElementById('prodAutocompleteList').classList.add('d-none');

                new bootstrap.Modal(document.getElementById('exchangeModal')).show();
            });
        });
    }

    // ── Return button handler ──────────────────────────────────
    function attachReturnButtons() {
        document.querySelectorAll('.open-return-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                if (customerUpdateRequired) {
                    Swal.fire('Customer Required', 'Please assign the actual customer before return.', 'warning');
                    openCustomerUpdateModal();
                    return;
                }
                const detailId  = this.dataset.detailId;
                const prodName  = this.dataset.prodName;
                const maxQty    = parseFloat(this.dataset.qty);
                const total     = parseFloat(this.dataset.total);
                const billNo    = document.getElementById('billNoInput').value.trim();

                // Step 1 – ask how many to return
                Swal.fire({
                    title: 'Return Quantity',
                    html: `<div class="mb-2 text-start">
                               <strong>${escHtml(prodName)}</strong><br>
                               <span class="text-muted small">Available qty: ${maxQty} &nbsp;|&nbsp; Total: ₹${total.toFixed(2)}</span>
                           </div>
                           <input id="swal-ret-qty" type="number" class="swal2-input"
                               min="0.001" max="${maxQty}" step="0.001"
                               placeholder="Enter qty to return" value="${maxQty}">`,
                    icon: 'question',
                    showCancelButton: true,
                    confirmButtonText: 'Next',
                    cancelButtonText: 'Cancel',
                    preConfirm: () => {
                        const val = parseFloat(document.getElementById('swal-ret-qty').value);
                        if (isNaN(val) || val <= 0) {
                            Swal.showValidationMessage('Please enter a valid quantity greater than 0.');
                            return false;
                        }
                        if (val > maxQty) {
                            Swal.showValidationMessage('Qty cannot exceed available qty (' + maxQty + ').');
                            return false;
                        }
                        return val;
                    }
                }).then(step1 => {
                    if (!step1.isConfirmed) return;
                    const returnQty  = step1.value;
                    const retAmount  = parseFloat(((returnQty / maxQty) * total).toFixed(2));

                    // Step 2 – confirm
                    Swal.fire({
                        title: 'Confirm Return?',
                        html: `Return <strong>${escHtml(prodName)}</strong><br>
                               Qty: <strong>${returnQty}</strong> of ${maxQty}
                               &nbsp;|&nbsp; Amount: ₹<strong>${retAmount.toFixed(2)}</strong><br><br>
                               <span class="text-success">Stock will be restored and customer earns ₹${retAmount.toFixed(2)} exchange points.</span>`,
                        icon: 'warning',
                        showCancelButton: true,
                        confirmButtonText: 'Yes, Return',
                        confirmButtonColor: '#fd7e14',
                        cancelButtonText: 'Cancel'
                    }).then(result => {
                        if (!result.isConfirmed) return;

                        const params = new URLSearchParams({ billNo, detailId, returnQty });
                        fetch(CTX + '/admin/Exchange/saveReturn.jsp', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                            body: params.toString()
                        })
                        .then(r => r.json())
                        .then(data => {
                            if (data.success) {
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Return Successful',
                                    html: data.message,
                                    confirmButtonText: 'OK'
                                }).then(() => loadBill());
                            } else {
                                Swal.fire('Error', data.message || 'Return failed.', 'error');
                            }
                        })
                        .catch(() => Swal.fire('Error', 'Network error.', 'error'));
                    });
                });
            });
        });
    }

    // ── Customer Update Modal ───────────────────────────────────
    let custNameTimer = null, custPhoneTimer = null;

    function openCustomerUpdateModal() {
        document.getElementById('custNameInput').value = '';
        document.getElementById('custPhoneInput').value = '';
        document.getElementById('custIdInput').value = '';
        hideCustLists();
        new bootstrap.Modal(document.getElementById('customerUpdateModal')).show();
        setTimeout(() => document.getElementById('custNameInput').focus(), 300);
    }

    function hideCustLists() {
        document.getElementById('custNameList').classList.add('d-none');
        document.getElementById('custPhoneList').classList.add('d-none');
    }

    function selectCustomerForBill(c) {
        document.getElementById('custNameInput').value = c.name || '';
        document.getElementById('custPhoneInput').value = (c.phone && c.phone !== '-') ? c.phone : '';
        document.getElementById('custIdInput').value = c.id || '';
        hideCustLists();
    }

    function renderCustAutocomplete(listId, customers, onSelect) {
        const list = document.getElementById(listId);
        list.innerHTML = '';
        if (!customers || customers.length === 0) { list.classList.add('d-none'); return; }
        customers.forEach(c => {
            const li = document.createElement('li');
            li.textContent = c.name + (c.phone && c.phone !== '-' ? ' — ' + c.phone : '');
            li.addEventListener('click', () => onSelect(c));
            list.appendChild(li);
        });
        list.classList.remove('d-none');
    }

    document.getElementById('custNameInput').addEventListener('input', function() {
        clearTimeout(custNameTimer);
        const q = this.value.trim();
        document.getElementById('custIdInput').value = '';
        if (q.length < 2) { document.getElementById('custNameList').classList.add('d-none'); return; }
        custNameTimer = setTimeout(() => {
            fetch(CTX + '/billing/customerAutocomplete.jsp?query=' + encodeURIComponent(q))
                .then(r => r.json())
                .then(arr => renderCustAutocomplete('custNameList', arr, selectCustomerForBill))
                .catch(() => {});
        }, 250);
    });

    document.getElementById('custPhoneInput').addEventListener('input', function() {
        clearTimeout(custPhoneTimer);
        const q = this.value.trim();
        document.getElementById('custIdInput').value = '';
        if (q.length < 3) { document.getElementById('custPhoneList').classList.add('d-none'); return; }
        custPhoneTimer = setTimeout(() => {
            fetch(CTX + '/billing/customerAutocomplete.jsp?phone=' + encodeURIComponent(q))
                .then(r => r.json())
                .then(arr => renderCustAutocomplete('custPhoneList', arr, selectCustomerForBill))
                .catch(() => {});
        }, 250);
    });

    document.getElementById('confirmCustomerBtn').addEventListener('click', function() {
        const customerId = parseInt(document.getElementById('custIdInput').value) || 0;
        const cusName    = document.getElementById('custNameInput').value.trim();
        const cusPhn     = document.getElementById('custPhoneInput').value.trim();

        if (!cusName) {
            Swal.fire('Validation', 'Customer name is required.', 'warning');
            return;
        }

        const params = new URLSearchParams({
            billId: currentBillData.billId,
            customerId: customerId,
            cusName: cusName,
            cusPhn: cusPhn
        });

        fetch(CTX + '/admin/Exchange/updateBillCustomer.jsp', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: params.toString()
        })
        .then(r => r.json())
        .then(data => {
            if (!data.success) {
                Swal.fire('Error', data.message || 'Failed to update customer.', 'error');
                return;
            }
            customerUpdateRequired = false;
            currentBillData.customerId = data.customerId;
            currentBillData.cusName = data.cusName;
            bootstrap.Modal.getInstance(document.getElementById('customerUpdateModal')).hide();
            renderBill(currentBillData);
            Swal.fire({ icon: 'success', title: 'Customer Updated', text: data.message, timer: 1800, showConfirmButton: false });
        })
        .catch(() => Swal.fire('Error', 'Network error.', 'error'));
    });

    document.addEventListener('click', function(e) {
        if (!e.target.closest('#custNameInput') && !e.target.closest('#custNameList')) {
            document.getElementById('custNameList').classList.add('d-none');
        }
        if (!e.target.closest('#custPhoneInput') && !e.target.closest('#custPhoneList')) {
            document.getElementById('custPhoneList').classList.add('d-none');
        }
    });

    // ── Product Autocomplete ────────────────────────────────────
    let acTimer = null;
    document.getElementById('newProdSearch').addEventListener('input', function() {
        clearTimeout(acTimer);
        const q = this.value.trim();
        if (q.length < 2) {
            document.getElementById('prodAutocompleteList').classList.add('d-none');
            return;
        }
        acTimer = setTimeout(() => {
            fetch(CTX + '/admin/Exchange/searchProductForExchange.jsp?term=' + encodeURIComponent(q))
                .then(r => r.json())
                .then(arr => renderAutocomplete(arr))
                .catch(() => {});
        }, 250);
    });

    function renderAutocomplete(arr) {
        const list = document.getElementById('prodAutocompleteList');
        list.innerHTML = '';
        if (!arr || arr.length === 0) { list.classList.add('d-none'); return; }
        arr.forEach(item => {
            const li = document.createElement('li');
            li.textContent = (item.code ? item.name + ' (' + item.code + ')' : item.name) + ' — ₹' + item.price;
            li.addEventListener('click', () => {
                document.getElementById('newProdSearch').value = item.name;
                document.getElementById('newProdId').value = item.id;
                document.getElementById('newPrice').value = item.price;
                list.classList.add('d-none');
                updatePriceDiff();
            });
            list.appendChild(li);
        });
        list.classList.remove('d-none');
    }

    document.getElementById('newPrice').addEventListener('input', updatePriceDiff);

    function updatePriceDiff() {
        const newPrice = parseFloat(document.getElementById('newPrice').value) || 0;
        const newTotal = newPrice * currentQty;
        const diff = newTotal - currentOldTotal;
        const hint = document.getElementById('priceDiffHint');
        if (newPrice <= 0) { hint.textContent = ''; return; }
        if (diff < 0) {
            hint.innerHTML = `<span class="text-success"><i class="fa-solid fa-arrow-down me-1"></i>Lower by \u20b9${Math.abs(diff).toFixed(2)} — customer earns exchange points</span>`;
        } else if (diff > 0) {
            hint.innerHTML = `<span class="text-danger"><i class="fa-solid fa-arrow-up me-1"></i>Higher by \u20b9${diff.toFixed(2)} — bill amount will increase</span>`;
        } else {
            hint.innerHTML = `<span class="text-secondary">Same amount — no change to bill or points</span>`;
        }
    }

    // Close autocomplete on outside click
    document.addEventListener('click', function(e) {
        if (!e.target.closest('.prod-search-input')) {
            document.getElementById('prodAutocompleteList').classList.add('d-none');
        }
    });

    // ── Confirm Exchange ────────────────────────────────────────
    document.getElementById('confirmExchangeBtn').addEventListener('click', function() {
        const newProdId = document.getElementById('newProdId').value.trim();
        const newPrice  = document.getElementById('newPrice').value.trim();
        const billNo    = document.getElementById('billNoInput').value.trim();

        if (!newProdId) { Swal.fire('Validation', 'Please select a product from the list.', 'warning'); return; }
        if (!newPrice || parseFloat(newPrice) <= 0) { Swal.fire('Validation', 'Please enter a valid price.', 'warning'); return; }

        Swal.fire({
            title: 'Confirm Exchange?',
            text: 'This will update the bill and product details. Continue?',
            icon: 'question',
            showCancelButton: true,
            confirmButtonText: 'Yes, Exchange',
            cancelButtonText: 'Cancel'
        }).then(result => {
            if (!result.isConfirmed) return;

            const params = new URLSearchParams({
                billNo:    billNo,
                detailId:  currentDetailId,
                newProdId: newProdId,
                newPrice:  newPrice
            });

            fetch(CTX + '/admin/Exchange/saveExchange.jsp', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params.toString()
            })
            .then(r => r.json())
            .then(data => {
                if (data.success) {
                    bootstrap.Modal.getInstance(document.getElementById('exchangeModal')).hide();
                    Swal.fire({
                        icon: 'success',
                        title: 'Exchange Successful',
                        html: data.message,
                        confirmButtonText: 'OK'
                    }).then(() => loadBill());
                } else {
                    Swal.fire('Error', data.message || 'Exchange failed.', 'error');
                }
            })
            .catch(() => Swal.fire('Error', 'Network error.', 'error'));
        });
    });

    function escHtml(str) {
        if (!str) return '-';
        return String(str).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
    }
    </script>
</body>
</html>
