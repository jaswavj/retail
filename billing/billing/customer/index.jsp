<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Customers Balance</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
<jsp:include page="/assets/navbar/navbar.jsp" />
<%
    request.setAttribute("pageTitle",    "Customers Balance");
    request.setAttribute("pageSubtitle", "Credit Management — Customer Account");
    request.setAttribute("pageIcon",     "fa-solid fa-users");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container mt-5 mst-page" style="max-width:520px;">
    <div class="card shadow-sm">
        <div class="card-body p-4">
            <h5 class="mb-4" style="font-weight:700;">
                <i class="fa-solid fa-magnifying-glass me-2"></i>Search Customer
            </h5>

            <div style="position:relative;">
                <input type="text" id="customerSearch" class="form-control fg-inp"
                       placeholder="Type name or phone number..." autocomplete="off"
                       style="font-size:15px;height:42px;padding-right:40px;">
                <i class="fa-solid fa-user" style="position:absolute;right:13px;top:50%;transform:translateY(-50%);opacity:.4;"></i>
                <ul id="customerDropdown" style="
                    display:none;position:absolute;top:100%;left:0;right:0;z-index:1000;
                    background:#fff;border:1.5px solid #d1d9e6;border-top:none;
                    border-radius:0 0 8px 8px;list-style:none;padding:0;margin:0;
                    max-height:260px;overflow-y:auto;box-shadow:0 4px 16px rgba(0,0,0,.10);
                "></ul>
            </div>

            <div id="selectedCustomerBox" style="display:none;margin-top:18px;
                border:1.5px solid #22c55e;border-radius:8px;padding:14px 16px;background:#f0fdf4;">
                <div style="display:flex;justify-content:space-between;align-items:center;">
                    <div>
                        <div style="font-weight:700;font-size:15px;" id="selName"></div>
                        <div style="font-size:13px;color:#555;margin-top:2px;" id="selPhone"></div>
                    </div>
                    <button class="btn btn-sm btn-success" onclick="goToView()">
                        View Account <i class="fa-solid fa-arrow-right ms-1"></i>
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
const contextPath = '<%=request.getContextPath()%>';
let selectedCustomerId = null;
let searchTimer = null;

const searchInput = document.getElementById('customerSearch');
const dropdown   = document.getElementById('customerDropdown');

searchInput.addEventListener('input', function() {
    const val = this.value.trim();
    clearTimeout(searchTimer);
    dropdown.style.display = 'none';
    document.getElementById('selectedCustomerBox').style.display = 'none';
    selectedCustomerId = null;

    if (val.length < 1) return;

    searchTimer = setTimeout(() => {
        // detect phone search if value is mostly digits
        const isPhone = /^\d+$/.test(val);
        const params  = isPhone ? 'phone=' + encodeURIComponent(val)
                                : 'query=' + encodeURIComponent(val);
        fetch(contextPath + '/billing/customerAutocomplete.jsp?' + params)
            .then(r => r.json())
            .then(data => renderDropdown(data))
            .catch(() => {});
    }, 280);
});

function renderDropdown(customers) {
    dropdown.innerHTML = '';
    if (!customers.length) {
        dropdown.innerHTML = '<li style="padding:10px 14px;color:#888;font-size:13px;">No customers found</li>';
        dropdown.style.display = 'block';
        return;
    }
    customers.forEach(c => {
        const li = document.createElement('li');
        li.style.cssText = 'padding:10px 14px;cursor:pointer;border-bottom:1px solid #f0f0f0;';
        li.innerHTML = '<span style="font-weight:600;">' + c.name + '</span>'
                     + '<span style="font-size:12px;color:#888;margin-left:8px;">' + (c.phone !== '-' ? c.phone : '') + '</span>';
        li.addEventListener('mouseenter', () => li.style.background = '#f1f5f9');
        li.addEventListener('mouseleave', () => li.style.background = '');
        li.addEventListener('click', () => selectCustomer(c));
        dropdown.appendChild(li);
    });
    dropdown.style.display = 'block';
}

function selectCustomer(c) {
    selectedCustomerId = c.id;
    searchInput.value  = c.name + (c.phone && c.phone !== '-' ? '  |  ' + c.phone : '');
    dropdown.style.display = 'none';
    document.getElementById('selName').textContent  = c.name;
    document.getElementById('selPhone').textContent = c.phone && c.phone !== '-' ? c.phone : '';
    document.getElementById('selectedCustomerBox').style.display = 'block';
}

function goToView() {
    if (!selectedCustomerId) return;
    window.location.href = contextPath + '/billing/customer/view.jsp?customerId=' + selectedCustomerId;
}

// Close dropdown on outside click
document.addEventListener('click', function(e) {
    if (!searchInput.contains(e.target) && !dropdown.contains(e.target)) {
        dropdown.style.display = 'none';
    }
});

// Enter key
searchInput.addEventListener('keydown', function(e) {
    if (e.key === 'Enter' && selectedCustomerId) goToView();
});
</script>
</body>
</html>
