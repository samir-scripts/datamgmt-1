<%@ page import="java.sql.*" %>
<%@ page import="com.train.util.DatabaseConnection" %>
<%
    String user = request.getParameter("username");
    String pass = request.getParameter("password");

    if(user == null || pass == null || user.trim().isEmpty() || pass.trim().isEmpty()) {
        response.sendRedirect("login.jsp?error=Please enter username and password.");
        return;
    }

    Connection con = null;
    PreparedStatement pstEmp = null;
    PreparedStatement pstCus = null;
    ResultSet rsEmp = null;
    ResultSet rsCus = null;

    try {
        con = DatabaseConnection.getConnection();

        // Check EMPLOYEE table first
        String queryEmp = "SELECT ssn, role FROM EMPLOYEE WHERE username = ? AND password = ?";
        pstEmp = con.prepareStatement(queryEmp);
        pstEmp.setString(1, user);
        pstEmp.setString(2, pass);
        rsEmp = pstEmp.executeQuery();

        if (rsEmp.next()) {
            session.setAttribute("user", user);
            session.setAttribute("role", rsEmp.getString("role"));
            session.setAttribute("userId", rsEmp.getString("ssn"));

            if ("admin".equalsIgnoreCase(rsEmp.getString("role"))) {
                response.sendRedirect("admin/admin_dashboard.jsp");
            } else if ("customer_rep".equalsIgnoreCase(rsEmp.getString("role"))) {
                response.sendRedirect("rep/rep_dashboard.jsp");
            }
            return;
        }

        // Check CUSTOMER table
        String queryCus = "SELECT cid, first_name, last_name FROM CUSTOMER WHERE username = ? AND password = ?";
        pstCus = con.prepareStatement(queryCus);
        pstCus.setString(1, user);
        pstCus.setString(2, pass);
        rsCus = pstCus.executeQuery();

        if (rsCus.next()) {
            session.setAttribute("user", user);
            session.setAttribute("role", "customer");
            session.setAttribute("userId", rsCus.getInt("cid"));
            session.setAttribute("fullName", rsCus.getString("first_name") + " " + rsCus.getString("last_name"));

            response.sendRedirect("customer/customer_dashboard.jsp");
            return;
        }

        // If no match found; can you guys look into this
        response.sendRedirect("login.jsp?error=Invalid username or password.");

    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("login.jsp?error=Database error occurred.");
    } finally {
        if(rsEmp != null) rsEmp.close();
        if(rsCus != null) rsCus.close();
        if(pstEmp != null) pstEmp.close();
        if(pstCus != null) pstCus.close();
        if(con != null) con.close();
    }
%>
