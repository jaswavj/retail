<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<%
String today = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Day Book</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
<%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "Day Book");
    request.setAttribute("pageSubtitle", "Account Reports — Day Book");
    request.setAttribute("pageIcon",     "fa-solid fa-book-open");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container-fluid mt-3 mst-page">
    <form action="<%=contextPath%>/reports/dayBook/report.jsp" method="get" class="row g-3 align-items-end">
        <div class="col-md-3">
            <label for="fromDate" class="form-label">From Date</label>
            <input type="date" id="fromDate" name="fromDate" value="<%=today%>" class="form-control" required>
        </div>
        <div class="col-md-3">
            <label for="toDate" class="form-label">To Date</label>
            <input type="date" id="toDate" name="toDate" value="<%=today%>" class="form-control" required>
        </div>
        <div class="col-md-3">
            <button type="submit" class="bb bb-primary w-100">
                <i class="fa-solid fa-book-open me-1"></i>Generate Day Book
            </button>
        </div>
        <div class="col-md-3">
            <button type="button" class="bb bb-outline w-100" data-bs-toggle="modal" data-bs-target="#openingBalanceModal" title="Add Opening Balance">
                <i class="fa-solid fa-wallet me-1"></i>Opening Balance
            </button>
        </div>
    </form>
</div>

<!-- Opening Balance Modal -->
<div class="modal fade" id="openingBalanceModal" tabindex="-1" aria-labelledby="openingBalanceModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="openingBalanceModalLabel">
                    <i class="fa-solid fa-wallet me-2"></i>Add Opening Balance
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="row g-3 mb-3">
                    <div class="col-md-4">
                        <label class="form-label fw-bold">Date</label>
                        <input type="date" id="obDate" class="form-control" value="<%=today%>">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-bold">Amount</label>
                        <input type="number" id="obAmount" class="form-control" step="0.01" placeholder="0.00" oninput="obUpdatePaymentFields()">
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-bold">Notes <span class="text-muted fw-normal">(optional)</span></label>
                        <input type="text" id="obNotes" class="form-control" placeholder="Opening cash in hand">
                    </div>
                </div>
                <div class="row g-3 mb-3">
                    <div class="col-md-4">
                        <label class="form-label fw-bold">Pay Mode</label>
                        <select id="obPayMode" class="form-select" onchange="obOnModeChange()">
                            <option value="1">Cash</option>
                            <option value="2">Bank</option>
                            <option value="3">Mixed</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-bold">Pay Type</label>
                        <select id="obPayType" class="form-select">
                            <option value="0">—</option>
                            <option value="1">UPI</option>
                            <option value="2">Debit Card</option>
                            <option value="3">Credit Card</option>
                            <option value="4">Net Banking</option>
                            <option value="5">Wallet</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-bold">Cash Paid</label>
                        <input type="number" id="obCashPaid" class="form-control" step="0.01" value="0.00">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Bank Paid</label>
                        <input type="number" id="obBankPaid" class="form-control" step="0.01" value="0.00">
                    </div>
                </div>
                <div class="d-flex gap-2 mb-3">
                    <button type="button" class="bb bb-primary" onclick="saveOpeningBalance()">
                        <i class="fa-solid fa-floppy-disk me-1"></i>Save
                    </button>
                </div>
                <div class="table-responsive" style="max-height:280px;">
                    <table class="table table-sm mst-table">
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th class="text-end">Amount</th>
                                <th>Cash / Bank</th>
                                <th>Notes</th>
                                <th>User</th>
                            </tr>
                        </thead>
                        <tbody id="obListBody">
                            <tr><td colspan="5" class="text-center text-muted">Loading...</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
const obContextPath = '<%=contextPath%>';

function obPayDisplay(row) {
    const cash = parseFloat(row.cashPaid) || 0;
    const bank = parseFloat(row.bankPaid) || 0;
    if (row.payLabel === 'Mixed') {
        return 'Cash ₹' + cash.toFixed(2) + ' / Bank ₹' + bank.toFixed(2);
    }
    if (row.payLabel === 'Bank') {
        return 'Bank ₹' + (bank > 0 ? bank : parseFloat(row.amount)).toFixed(2);
    }
    return 'Cash ₹' + (cash > 0 ? cash : parseFloat(row.amount)).toFixed(2);
}

function loadOpeningBalanceList() {
    fetch(obContextPath + '/reports/dayBook/getOpeningBalanceList.jsp')
        .then(r => r.json())
        .then(data => {
            const tbody = document.getElementById('obListBody');
            if (!data.length) {
                tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted">No opening balance entries yet.</td></tr>';
                return;
            }
            tbody.innerHTML = data.map(row =>
                '<tr><td>' + row.balanceDate + '</td>' +
                '<td class="text-end fw-bold">' + parseFloat(row.amount).toFixed(2) + '</td>' +
                '<td>' + obPayDisplay(row) + '</td>' +
                '<td>' + (row.notes || '-') + '</td>' +
                '<td>' + (row.userName || '-') + '</td></tr>'
            ).join('');
        })
        .catch(() => {
            document.getElementById('obListBody').innerHTML =
                '<tr><td colspan="5" class="text-center text-danger">Could not load list. Run daybook_opening_balance_setup.sql if table is missing.</td></tr>';
        });
}

function obTogglePayType() {
    const mode = document.getElementById('obPayMode').value;
    const typeSelect = document.getElementById('obPayType');
    if (mode === '1') {
        typeSelect.disabled = true;
        typeSelect.value = '0';
    } else {
        typeSelect.disabled = false;
        if (!typeSelect.value || typeSelect.value === '0') typeSelect.value = '1';
    }
}

function obUpdatePaymentFields() {
    const payable = parseFloat(document.getElementById('obAmount').value) || 0;
    const mode = document.getElementById('obPayMode').value;
    const cashInp = document.getElementById('obCashPaid');
    const bankInp = document.getElementById('obBankPaid');
    cashInp.oninput = null;
    bankInp.oninput = null;
    if (mode === '1') {
        cashInp.disabled = false;
        bankInp.disabled = true;
        cashInp.value = payable.toFixed(2);
        bankInp.value = '0.00';
    } else if (mode === '2') {
        cashInp.disabled = true;
        bankInp.disabled = false;
        cashInp.value = '0.00';
        bankInp.value = payable.toFixed(2);
    } else {
        cashInp.disabled = false;
        bankInp.disabled = false;
        cashInp.value = payable.toFixed(2);
        bankInp.value = '0.00';
        cashInp.oninput = function() {
            const cash = parseFloat(cashInp.value) || 0;
            bankInp.value = Math.max(0, payable - cash).toFixed(2);
        };
        bankInp.oninput = function() {
            const bank = parseFloat(bankInp.value) || 0;
            cashInp.value = Math.max(0, payable - bank).toFixed(2);
        };
    }
}

function obOnModeChange() {
    obTogglePayType();
    obUpdatePaymentFields();
}

function saveOpeningBalance() {
    const balanceDate = document.getElementById('obDate').value;
    const amount = parseFloat(document.getElementById('obAmount').value) || 0;
    const notes = document.getElementById('obNotes').value;
    const payMode = document.getElementById('obPayMode').value;
    const payType = document.getElementById('obPayType').value;
    const cashPaid = parseFloat(document.getElementById('obCashPaid').value) || 0;
    const bankPaid = parseFloat(document.getElementById('obBankPaid').value) || 0;
    if (!balanceDate || amount <= 0) {
        Swal.fire({ icon: 'warning', title: 'Required', text: 'Please enter date and amount.' });
        return;
    }
    if (Math.abs((cashPaid + bankPaid) - amount) > 0.01) {
        Swal.fire({ icon: 'warning', title: 'Payment', text: 'Cash + Bank must equal the amount.' });
        return;
    }
    const body = new URLSearchParams({
        balanceDate, amount: amount.toFixed(2), notes,
        payMode, payType,
        cashPaid: cashPaid.toFixed(2),
        bankPaid: bankPaid.toFixed(2)
    });
    fetch(obContextPath + '/reports/dayBook/saveOpeningBalance.jsp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: body.toString()
    })
    .then(r => r.json())
    .then(res => {
        if (res.success) {
            Swal.fire({ icon: 'success', title: 'Saved', text: res.message, timer: 1800, showConfirmButton: false });
            document.getElementById('obAmount').value = '';
            document.getElementById('obNotes').value = '';
            loadOpeningBalanceList();
        } else {
            Swal.fire({ icon: 'error', title: 'Error', text: res.message });
        }
    })
    .catch(() => Swal.fire({ icon: 'error', title: 'Error', text: 'Could not save opening balance.' }));
}

document.getElementById('openingBalanceModal').addEventListener('show.bs.modal', function() {
    loadOpeningBalanceList();
    obOnModeChange();
});
</script>
</body>
</html>
