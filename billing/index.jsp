<%@page language="java" import="java.util.*" %>
<%!
// Password hashing utility - Updated to SHA-512 to match existing hashes
private String hashPassword(String password) throws Exception {
    java.security.MessageDigest md = java.security.MessageDigest.getInstance("SHA-512");
    byte[] hash = md.digest(password.getBytes("UTF-8"));
    StringBuilder sb = new StringBuilder();
    for (byte b : hash) {
        sb.append(String.format("%02x", b));
    }
    return sb.toString();
}
%>
<%
// Prevent caching - force fresh page load
response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);
%>
<jsp:useBean id="prod" class="user.userBean" scope="session" />
<%
String submittedUser = request.getParameter("username");
String submittedPass = request.getParameter("password");

boolean loginFailed = false;
boolean licenseExpired = false;

if (submittedUser != null && submittedPass != null) {
    Vector userAndPass = prod.getUserCredential(); // fetch from DB
    boolean matched = false;

    for (int i = 0; i < userAndPass.size(); i++) {
        Vector row = (Vector) userAndPass.get(i);
        String dbUser = row.elementAt(0).toString();
        String dbPass = row.elementAt(1).toString();
        int userId = Integer.parseInt(row.elementAt(2).toString());

        if (submittedUser.equals(dbUser) && hashPassword(submittedPass).equals(dbPass)) {
            // Check license validity before allowing login
            try {
                if (!prod.checkLicenseValidity()) {
                    licenseExpired = true;
                    break;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            
            // Success - Redirect to dashboard
            session.setAttribute("userId", userId);
            session.setAttribute("username", dbUser);
            response.sendRedirect(request.getContextPath() + "/billing/app.jsp");

            
            return;
        }
    }

    if (!licenseExpired) {
        loginFailed = true; // No match found
    }
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Login - Billing App</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <!-- Bootstrap CSS -->
  <link href="dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="dist/fonts/css/all.min.css">
  <link rel="stylesheet" href="assets/css/theme.css">
</head>
<body class="login-body">

  <!-- Animated Background Elements -->
  <div class="bg-shapes">
    <div class="shape shape-1"></div>
    <div class="shape shape-2"></div>
    <div class="shape shape-3"></div>
  </div>

  <div class="login-wrapper">
    <!-- Hero Section -->
    <div class="hero-section">
        <div class="brand-section">
          
          <h3 class="brand-title">JASXBILL</h3>
          <p class="brand-tagline">Smart Business Management System</p>

      </div>
    </div>

    <!-- Login Section -->
    <div class="login-section">
      <div class="login-card-modern">
        <div class="card-header-modern">
          <h2>Welcome Back</h2>
          <p>Sign in to access your dashboard</p>
        </div>        
        <form action="<%=request.getContextPath()%>/index.jsp" method="post" name="form" id="form" class="modern-form">
          <div class="form-group-modern">
            <label for="username" class="modern-label">
              <i class="fa-solid fa-user"></i>
              Username
            </label>
            <input type="text" 
                   class="modern-input" 
                   id="username" 
                   name="username" 
                   placeholder="Enter your username" 
                   required 
                   autofocus>
          </div>

          <div class="form-group-modern">
            <label for="password" class="modern-label">
              <i class="fa-solid fa-lock"></i>
              Password
            </label>
            <input type="password" 
                   class="modern-input" 
                   id="password" 
                   name="password" 
                   placeholder="Enter your password" 
                   required>
          </div>

          <% if (loginFailed) { %>
            <div class="alert-modern alert-error">
              <i class="fas fa-exclamation-circle"></i>
              <span>Invalid username or password. Please try again.</span>
            </div>
          <% } %>
          
          <% if (licenseExpired) { %>
            <div class="alert-modern alert-warning">
              <i class="fas fa-exclamation-triangle"></i>
              <div>
                <strong>Software License Expired!</strong>
                <p>Contact Software Team: 8667214152 </p>
              </div>
            </div>
          <% } %>

          <button type="submit" class="btn-modern btn-primary-modern">
            <i class="fa-solid fa-right-to-bracket"></i>
            <span>Sign In</span>
          </button>
        </form>
        
        <div class="card-footer-modern">
          <p><i class="fas fa-info-circle"></i> Contact your administrator for account access</p>
        </div>
      </div>
    </div>

  </div>

  <!-- Feature Cards Section -->
  <div class="features-bottom">
    <div class="feature-card-modern">
      <div class="feature-icon-modern">
        <i class="fas fa-file-invoice"></i>
      </div>
      <h3>Smart Invoicing</h3>
      <p>Generate professional invoices with automated GST calculations</p>
    </div>
    <div class="feature-card-modern">
      <div class="feature-icon-modern">
        <i class="fas fa-warehouse"></i>
      </div>
      <h3>Inventory Management</h3>
      <p>Track stock, suppliers, and purchase orders in real-time</p>
    </div>
    <div class="feature-card-modern">
      <div class="feature-icon-modern">
        <i class="fas fa-chart-bar"></i>
      </div>
      <h3>Business Analytics</h3>
      <p>Get insights with powerful reports and dashboards</p>
    </div>
    <div class="feature-card-modern">
      <div class="feature-icon-modern">
        <i class="fas fa-calculator"></i>
      </div>
      <h3>GST Compliance</h3>
      <p>Automated tax calculations and compliance reports</p>
    </div>
  </div>


  <!-- Modern Footer -->
  <footer class="modern-footer">
    <div class="footer-container">
      <div class="footer-brand">
        <i class="fas fa-headset"></i>
        <span>24/7 Support Available</span>
      </div>
      <div class="footer-contacts">
        <a href="mailto:jaswavj@gmail.com" class="footer-link">
          <i class="fa-solid fa-envelope"></i>
          jaswavj@gmail.com
        </a>
        <a href="tel:+918667214152" class="footer-link">
          <i class="fa-solid fa-phone"></i>
          +91 8667214152 or +91 9597451419
        </a>
      </div>
    </div>
  </footer>

<!-- Bootstrap JS -->
<script src="dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
