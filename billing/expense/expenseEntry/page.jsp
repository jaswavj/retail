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
    <title>Expense Entry - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- Bootstrap CSS -->
    <%@ include file="/assets/common/head.jsp" %>

</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "Expense Entry");
    request.setAttribute("pageSubtitle", "Add a new expense record");
    request.setAttribute("pageIcon",     "fa-solid fa-receipt");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container-fluid mt-3 mst-page" style="max-width:900px;">
<%
String msg = request.getParameter("msg");
String type = request.getParameter("type");
%>
<% if (msg != null) { %>
<div class="alert alert-<%= (type != null ? type : "info") %> alert-dismissible fade show mb-3" role="alert">
  <%= msg %>
  <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
</div>
<% } %>
    <div class="card mst-card">
        <div class="mst-card-header">
            <h5 class="mb-0"><i class="fa-solid fa-receipt me-2"></i>Add Expense Entry</h5>
        </div>
        <div class="card-body p-4">
                <form action="<%=contextPath%>/expense/expenseEntry/saveExpenseEntry.jsp" method="post" onsubmit="return validateForm()">
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Expense Type</label>
                            <select name="expenseType" id="expenseType" class="form-select fg-inp" required>
                                <option value="">-- Select Expense Type --</option>
                                <%
                                try {
                                    Vector expTypes = prod.getExpenseTypeList();
                                    for (int i = 0; i < expTypes.size(); i++) {
                                        Vector expType = (Vector) expTypes.get(i);
                                        String typeName = expType.elementAt(0).toString();
                                        String typeId = expType.elementAt(1).toString();
                                %>
                                    <option value="<%=typeId%>"><%=typeName%></option>
                                <%
                                    }
                                } catch (Exception e) {
                                    out.println("<option value=''>Error loading expense types</option>");
                                }
                                %>
                            </select>
                        </div>
                        
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Amount</label>
                            <input type="number" step="0.01" name="amount" id="amount" class="form-control fg-inp" placeholder="0.00" required>
                        </div>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Content</label>
                        <input type="text" name="content" id="content" class="form-control fg-inp" placeholder="Enter content" required>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Description</label>
                        <textarea name="description" id="description" class="form-control fg-inp" rows="4" placeholder="Type anything you want to store here"></textarea>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Date</label>
                            <input type="date" name="expenseDate" id="expenseDate" class="form-control fg-inp" required value="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
                        </div>
                        
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Time</label>
                            <input type="time" name="expenseTime" id="expenseTime" class="form-control fg-inp" required value="<%= new java.text.SimpleDateFormat("HH:mm").format(new java.util.Date()) %>">
                        </div>
                    </div>

                    <hr class="my-4">
                    <h6 class="fw-bold mb-3"><i class="fa-solid fa-money-bill-wave me-2"></i>Payment Details</h6>

                    <div class="row g-3 mb-3">
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Pay Mode</label>
                            <select name="payMode" id="payMode" class="form-select fg-inp" required>
                                <option value="1">Cash</option>
                                <option value="2">Bank</option>
                                <option value="3">Mixed</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Pay Type</label>
                            <select name="payType" id="payType" class="form-select fg-inp">
                                <option value="0">—</option>
                                <option value="1">UPI</option>
                                <option value="2">Debit Card</option>
                                <option value="3">Credit Card</option>
                                <option value="4">Net Banking</option>
                                <option value="5">Wallet</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Cash Paid</label>
                            <input type="number" step="0.01" name="cashPaid" id="cashPaid" class="form-control fg-inp" value="0.00">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Bank Paid</label>
                            <input type="number" step="0.01" name="bankPaid" id="bankPaid" class="form-control fg-inp" value="0.00">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Balance</label>
                            <input type="number" step="0.01" name="balance" id="balance" class="form-control fg-inp" value="0.00" readonly>
                        </div>
                    </div>
                    
                    <div class="d-flex gap-2 justify-content-end mt-4">
                        <button type="reset" class="bb bb-outline" onclick="setTimeout(initPaymentFields, 0)">
                            <i class="fa-solid fa-rotate-left me-2"></i>Reset
                        </button>
                        <button type="submit" class="bb bb-primary">
                            <i class="fa-solid fa-floppy-disk me-2"></i>Save Expense
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        function getPayable() {
            return parseFloat(document.getElementById('amount').value) || 0;
        }

        function togglePayType() {
            const mode = document.getElementById('payMode').value;
            const typeSelect = document.getElementById('payType');
            if (mode === '1') {
                typeSelect.disabled = true;
                typeSelect.value = '0';
            } else {
                typeSelect.disabled = false;
                if (!typeSelect.value || typeSelect.value === '0') typeSelect.value = '1';
            }
        }

        function updatePaymentFields() {
            const payable = getPayable();
            const modeSelect = document.getElementById('payMode');
            const paidInput = document.getElementById('cashPaid');
            const bankPaidInput = document.getElementById('bankPaid');
            const balanceInput = document.getElementById('balance');

            paidInput.oninput = null;
            bankPaidInput.oninput = null;
            balanceInput.oninput = null;

            if (modeSelect.value === '1') {
                paidInput.disabled = false;
                bankPaidInput.disabled = true;
                balanceInput.disabled = true;
                paidInput.value = payable.toFixed(2);
                bankPaidInput.value = '0.00';
                balanceInput.value = Math.max(0, payable - parseFloat(paidInput.value || 0)).toFixed(2);
                paidInput.oninput = function () {
                    const paidVal = parseFloat(paidInput.value) || 0;
                    balanceInput.value = Math.max(0, payable - paidVal).toFixed(2);
                };
            } else if (modeSelect.value === '2') {
                paidInput.disabled = true;
                bankPaidInput.disabled = false;
                balanceInput.disabled = true;
                paidInput.value = '0.00';
                bankPaidInput.value = payable.toFixed(2);
                balanceInput.value = Math.max(0, payable - parseFloat(bankPaidInput.value || 0)).toFixed(2);
                bankPaidInput.oninput = function () {
                    const bankVal = parseFloat(bankPaidInput.value) || 0;
                    balanceInput.value = Math.max(0, payable - bankVal).toFixed(2);
                };
            } else {
                paidInput.disabled = false;
                bankPaidInput.disabled = false;
                balanceInput.disabled = false;
                paidInput.value = payable.toFixed(2);
                bankPaidInput.value = '0.00';
                balanceInput.value = '0.00';
                paidInput.oninput = function () {
                    const paidVal = parseFloat(paidInput.value) || 0;
                    const balVal = parseFloat(balanceInput.value) || 0;
                    bankPaidInput.value = Math.max(0, payable - paidVal - balVal).toFixed(2);
                };
                bankPaidInput.oninput = function () {
                    const bankVal = parseFloat(bankPaidInput.value) || 0;
                    const balVal = parseFloat(balanceInput.value) || 0;
                    paidInput.value = Math.max(0, payable - bankVal - balVal).toFixed(2);
                };
                balanceInput.oninput = function () {
                    const balVal = parseFloat(balanceInput.value) || 0;
                    const bankVal = parseFloat(bankPaidInput.value) || 0;
                    paidInput.value = Math.max(0, payable - bankVal - balVal).toFixed(2);
                };
            }
        }

        function initPaymentFields() {
            togglePayType();
            updatePaymentFields();
        }

        document.getElementById('amount').addEventListener('input', updatePaymentFields);
        document.getElementById('payMode').addEventListener('change', function () {
            togglePayType();
            updatePaymentFields();
        });

        function validateForm() {
            const expenseType = document.getElementById('expenseType').value;
            const amount = parseFloat(document.getElementById('amount').value) || 0;
            const content = document.getElementById('content').value;
            const expenseDate = document.getElementById('expenseDate').value;
            const expenseTime = document.getElementById('expenseTime').value;
            const cashPaid = parseFloat(document.getElementById('cashPaid').value) || 0;
            const bankPaid = parseFloat(document.getElementById('bankPaid').value) || 0;
            const balance = parseFloat(document.getElementById('balance').value) || 0;
            const payMode = document.getElementById('payMode').value;
            
            if (!expenseType) {
                alert('Please select an expense type');
                return false;
            }
            
            if (amount <= 0) {
                alert('Please enter a valid amount');
                return false;
            }
            
            if (!content.trim()) {
                alert('Please enter content');
                return false;
            }
            
            if (!expenseDate) {
                alert('Please select a date');
                return false;
            }
            
            if (!expenseTime) {
                alert('Please select a time');
                return false;
            }

            if (Math.abs((cashPaid + bankPaid + balance) - amount) > 0.01) {
                alert('Cash + Bank + Balance must equal the expense amount.');
                return false;
            }
            if (payMode === '1' && cashPaid <= 0 && balance <= 0) {
                alert('Please enter cash paid amount.');
                return false;
            }
            if (payMode === '2' && bankPaid <= 0 && balance <= 0) {
                alert('Please enter bank paid amount.');
                return false;
            }
            
            return true;
        }

        initPaymentFields();
    </script>

</body>
</html>
