<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<%

%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Customer - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <!-- Bootstrap CSS -->
    <%@ include file="/assets/common/head.jsp" %>

    <style>
        body {
            background: #f5f7fa;
        }
        .navbar {
            background-color: #4e73df;
        }
        .navbar-brand {
            color: #fff !important;
        }
        .table td, .table th {
            vertical-align: middle;
        }
        .btn-edit, .btn-delete {
            margin: 0 2px;
        }
        @media (max-width: 768px) {
            .container {
                padding-left: 0.5rem;
                padding-right: 0.5rem;
            }
            h3 {
                font-size: 1.25rem;
            }
        }

    </style>
    
</head>
<body onload="document.form.opregInput.focus();">

    <%@ include file="/assets/navbar/navbar.jsp" %>
    <!-- Top Navbar -->
<%
String msg  = request.getParameter("msg");
String type = request.getParameter("type");
%>

<% if (msg != null) { %>
<div class="alert alert-<%= (type != null ? type : "info") %> alert-dismissible fade show mt-3" role="alert">
  <%= msg %>
  <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
</div>
<% } %>


    <div class="container mt-4 ">
        <h3>Customer Details</h3>
        
        <!-- Add Customer Form -->
        <div class="card mb-4">
            <div class="card-body">
                <form id="customerForm" action="<%=contextPath%>/product/master/customer/page1.jsp" method="post" class="row g-3">
                    <input type="hidden" name="id" id="customerId" value="0">
                    <div class="col-md-6 input-outline">
                        <input type="text" name="custName" id="custName" class="form-control" placeholder="" required><label >Customer Name</label>
                    </div>
                    <div class="col-md-6 input-outline">
                        <input type="number" name="custPhn" id="custPhn" class="form-control" placeholder="" ><label >Phone Number</label>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="form-check mt-3">
                            <input class="form-check-input" type="checkbox" id="isGstRegistered" name="isGst" value="1" onchange="toggleGstinField()">
                            <label class="form-check-label" for="isGstRegistered">
                                GST Registered
                            </label>
                        </div>
                    </div>
                    
                    <div class="col-md-6 input-outline">
                        <input type="text" name="gstin" id="gstinField" class="form-control" placeholder="" maxlength="15" disabled>
                        <label>GSTIN <span class="text-danger" id="gstinRequired" style="display:none;">*</span></label>
                        <small id="gstinError" class="text-danger" style="display:none;">GSTIN must be exactly 15 characters</small>
                    </div>
                    
                    <div class="col-md-12 input-outline">
                        <textarea name="custAddress" id="custAddress" class="form-control" placeholder="Address" rows="3"></textarea>
                    </div>
                    
                    <div class="col-md-12">
                        <button type="submit" id="submitBtn" class="btn btn-primary">Add Customer</button>
                        <button type="button" id="cancelBtn" class="btn btn-secondary" onclick="resetForm()" style="display:none;">Cancel</button>
                    </div>
                </form>
            </div>
        </div>

        <script>
        function toggleGstinField() {
            const checkbox = document.getElementById('isGstRegistered');
            const gstinField = document.getElementById('gstinField');
            const gstinRequired = document.getElementById('gstinRequired');
            const gstinError = document.getElementById('gstinError');
            
            if (checkbox.checked) {
                gstinField.disabled = false;
                gstinField.required = true;
                gstinRequired.style.display = 'inline';
                gstinField.focus();
            } else {
                gstinField.disabled = true;
                gstinField.required = false;
                gstinField.value = '';
                gstinRequired.style.display = 'none';
                gstinError.style.display = 'none';
                gstinField.style.borderColor = '';
            }
        }
        
        // Real-time GSTIN validation
        document.addEventListener('DOMContentLoaded', function() {
            const gstinField = document.getElementById('gstinField');
            const gstinError = document.getElementById('gstinError');
            const isGstCheckbox = document.getElementById('isGstRegistered');
            const form = document.querySelector('form');
            
            // Real-time validation on input
            gstinField.addEventListener('input', function() {
                if (isGstCheckbox.checked) {
                    const length = this.value.length;
                    if (length > 0 && length !== 15) {
                        this.style.borderColor = '#dc3545';
                        gstinError.style.display = 'block';
                    } else if (length === 15) {
                        this.style.borderColor = '#28a745';
                        gstinError.style.display = 'none';
                    } else {
                        this.style.borderColor = '';
                        gstinError.style.display = 'none';
                    }
                }
            });
            
            // Form submit validation
            form.addEventListener('submit', function(e) {
                if (isGstCheckbox.checked) {
                    const gstinValue = gstinField.value.trim();
                    if (gstinValue.length !== 15) {
                        e.preventDefault();
                        gstinField.style.borderColor = '#dc3545';
                        gstinError.style.display = 'block';
                        gstinField.focus();
                        alert('GSTIN must be exactly 15 characters for GST registered customers');
                        return false;
                    }
                }
            });
        });
        
        // Edit customer function using event delegation
        document.addEventListener('DOMContentLoaded', function() {
            document.addEventListener('click', function(e) {
                if (e.target.closest('.edit-customer-btn')) {
                    const btn = e.target.closest('.edit-customer-btn');
                    const id = btn.getAttribute('data-id');
                    const name = btn.getAttribute('data-name');
                    const phone = btn.getAttribute('data-phone');
                    const gstin = btn.getAttribute('data-gstin');
                    const address = btn.getAttribute('data-address');
                    editCustomer(id, name, phone, gstin, address);
                }
            });
        });
        
        // Edit customer function
        function editCustomer(id, name, phone, gstin, address) {
            document.getElementById('customerId').value = id;
            document.getElementById('custName').value = name;
            document.getElementById('custPhn').value = phone;
            document.getElementById('gstinField').value = gstin;
            document.getElementById('custAddress').value = address;
            
            // Check if GST registered (ignore "-" as it means no GSTIN)
            const isGstCheckbox = document.getElementById('isGstRegistered');
            if (gstin && gstin.trim() !== '' && gstin.trim() !== '-') {
                isGstCheckbox.checked = true;
                document.getElementById('gstinField').disabled = false;
                document.getElementById('gstinRequired').style.display = 'inline';
            } else {
                isGstCheckbox.checked = false;
                document.getElementById('gstinField').disabled = true;
                document.getElementById('gstinRequired').style.display = 'none';
            }
            
            // Change form action and button text
            document.getElementById('customerForm').action = '<%=contextPath%>/product/master/customer/edit1.jsp';
            document.getElementById('submitBtn').textContent = 'Update Customer';
            document.getElementById('submitBtn').className = 'btn btn-success';
            document.getElementById('cancelBtn').style.display = 'inline-block';
            
            // Scroll to form
            document.getElementById('customerForm').scrollIntoView({ behavior: 'smooth' });
        }
        
        // Reset form function
        function resetForm() {
            document.getElementById('customerForm').reset();
            document.getElementById('customerId').value = '0';
            document.getElementById('customerForm').action = '<%=contextPath%>/product/master/customer/page1.jsp';
            document.getElementById('submitBtn').textContent = 'Add Customer';
            document.getElementById('submitBtn').className = 'btn btn-primary';
            document.getElementById('cancelBtn').style.display = 'none';
            document.getElementById('gstinField').disabled = true;
            document.getElementById('gstinRequired').style.display = 'none';
        }
        </script>

        <!-- Customer List Table -->
        
        <div class="card">
            <div class="card-body">
                <h5>Customer List</h5>
                <div class="table-responsive">
                <table class="table table-hover mb-0" style="border-collapse: separate; border-spacing: 0; min-width: 600px; table-layout: fixed;">
                    <thead style="background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%);">
                        <tr>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem; width: 5%;">#</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem; width: 8%;">Action</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem; width: 20%;">Name</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem; width: 15%;">Phone Number</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem; width: 18%;">GSTIN</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem; width: 34%;">Address</th>
                        </tr>
                    </thead>
                    <tbody>

                        <%
                            
                            Vector vec = prod.getCustomerDetails();
                            for (int i = 0; i < vec.size(); i++) {
                                Vector vec1 = (Vector) vec.get(i); // inner vector (row)
                                String Name =vec1.elementAt(0).toString();
                                int id			= Integer.parseInt(vec1.elementAt(1).toString());
                                String address =vec1.elementAt(2).toString();
                                String phn =vec1.elementAt(3).toString();
                                String gstin =vec1.elementAt(4).toString();


                        %>
                        <tr style="border-bottom: 1px solid #f1f5f9; transition: all 0.2s;">
                            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem; width: 5%;"><%=i+1%></td>
                            <td style="padding: 0.4rem; border: none; font-size: 0.9rem; width: 8%;">
                                <button class="btn btn-sm edit-customer-btn" style="background: var(--primary-gradient); color: white; border: none;" title="Edit"
                                    data-id="<%=id%>" 
                                    data-name="<%=Name%>" 
                                    data-phone="<%=phn%>" 
                                    data-gstin="<%=gstin%>"
                                    data-address="<%=address%>">
                                    <i class="fas fa-edit"></i>
                                </button>
                            </td>
                            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem; width: 20%; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="<%=Name%>"><%=Name%></td>
                            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem; width: 15%;"><%=phn%></td>
                            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem; width: 18%; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="<%=gstin%>"><%=gstin%></td>
                            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem; width: 34%; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="<%=address%>"><%=address%></td>
                        </tr>
                        <%
                    }
                        %>
                        <%-- Dynamic rows will come here --%>
                    </tbody>
                </table>
                </div>
            </div>
        </div>
    </div>
</div>
    <!-- Bootstrap JS -->
<script>
  // Disable right click for the whole document
  document.addEventListener('contextmenu', function (e) {
    e.preventDefault();
  });
</script>
</body>
</html>
