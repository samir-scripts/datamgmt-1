<%@ page import="java.sql.*" %>
<%@ page import="com.train.util.DatabaseConnection" %>
<%@ page session="true" %>
<%
    if (session.getAttribute("user") == null || !"admin".equals(session.getAttribute("role"))) {
        response.sendRedirect("../login.jsp?error=Unauthorized access.");
        return;
    }
    
    String action = request.getParameter("action");
    if ("add".equals(action)) {
        String ssn = request.getParameter("ssn");
        String fName = request.getParameter("first_name");
        String lName = request.getParameter("last_name");
        String uname = request.getParameter("username");
        String pass = request.getParameter("password");
        
        Connection con = null;
        PreparedStatement pst = null;
        try {
            con = DatabaseConnection.getConnection();
            String query = "INSERT INTO EMPLOYEE (ssn, first_name, last_name, username, password, role) VALUES (?, ?, ?, ?, ?, 'customer_rep')";
            pst = con.prepareStatement(query);
            pst.setString(1, ssn);
            pst.setString(2, fName);
            pst.setString(3, lName);
            pst.setString(4, uname);
            pst.setString(5, pass);
            pst.executeUpdate();
            response.sendRedirect("manage_reps.jsp?success=Rep added.");
            return;
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("manage_reps.jsp?error=Failed to add rep.");
            return;
        } finally {
            if(pst != null) pst.close();
            if(con != null) con.close();
        }
    } else if ("edit".equals(action)) {
        String ssn = request.getParameter("ssn");
        String fName = request.getParameter("first_name");
        String lName = request.getParameter("last_name");
        String pass = request.getParameter("password");
        
        Connection con = null;
        PreparedStatement pst = null;
        try {
            con = DatabaseConnection.getConnection();
            if (pass != null && !pass.trim().isEmpty()) {
                String query = "UPDATE EMPLOYEE SET first_name=?, last_name=?, password=? WHERE ssn=? AND role='customer_rep'";
                pst = con.prepareStatement(query);
                pst.setString(1, fName);
                pst.setString(2, lName);
                pst.setString(3, pass);
                pst.setString(4, ssn);
            } else {
                String query = "UPDATE EMPLOYEE SET first_name=?, last_name=? WHERE ssn=? AND role='customer_rep'";
                pst = con.prepareStatement(query);
                pst.setString(1, fName);
                pst.setString(2, lName);
                pst.setString(3, ssn);
            }
            pst.executeUpdate();
            response.sendRedirect("manage_reps.jsp?success=Rep updated.");
            return;
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("manage_reps.jsp?error=Failed to update rep.");
            return;
        } finally {
            if(pst != null) pst.close();
            if(con != null) con.close();
        }
    } else if ("delete".equals(action)) {
        String ssn = request.getParameter("ssn");
        Connection con = null;
        PreparedStatement pst = null;
        try {
            con = DatabaseConnection.getConnection();
            String query = "DELETE FROM EMPLOYEE WHERE ssn = ? AND role = 'customer_rep'";
            pst = con.prepareStatement(query);
            pst.setString(1, ssn);
            pst.executeUpdate();
            response.sendRedirect("manage_reps.jsp?success=Rep deleted.");
            return;
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("manage_reps.jsp?error=Failed to delete rep.");
            return;
        } finally {
            if(pst != null) pst.close();
            if(con != null) con.close();
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Representatives</title>
</head>
<body>
    <div class="container">
        <div class="nav-links">
            <a href="admin_dashboard.jsp">&larr; Dashboard</a>
        </div>
        <h2>Customer Representatives</h2>
        <%
            String successMsg = request.getParameter("success");
            String errorMsg = request.getParameter("error");
            if (successMsg != null) out.println("<div><font color='green'>" + successMsg + "</font></div><br>");
            if (errorMsg != null) out.println("<div><font color='red'>" + errorMsg + "</font></div><br>");
            
            String editSsn = request.getParameter("edit_ssn");
        %>
        
        <table border="1" cellpadding="5" cellspacing="0">
            <tr><th>SSN</th><th>First Name</th><th>Last Name</th><th>Username</th><th>Action</th></tr>
            <%
                Connection con = null;
                Statement st = null;
                ResultSet rs = null;
                try {
                    con = DatabaseConnection.getConnection();
                    st = con.createStatement();
                    rs = st.executeQuery("SELECT ssn, first_name, last_name, username FROM EMPLOYEE WHERE role = 'customer_rep'");
                    while(rs.next()) {
                        String s = rs.getString("ssn");
                        if (editSsn != null && editSsn.equals(s)) {
                            out.println("<tr><form action='manage_reps.jsp' method='POST'>");
                            out.println("<input type='hidden' name='action' value='edit'>");
                            out.println("<input type='hidden' name='ssn' value='" + s + "'>");
                            out.println("<td>" + s + "</td>");
                            out.println("<td><input type='text' name='first_name' value='" + rs.getString("first_name") + "' required></td>");
                            out.println("<td><input type='text' name='last_name' value='" + rs.getString("last_name") + "' required></td>");
                            out.println("<td>" + rs.getString("username") + "<br><small><input type='password' name='password' placeholder='New pass (optional)'></small></td>");
                            out.println("<td><input type='submit' value='Save'> | <a href='manage_reps.jsp'>Cancel</a></td>");
                            out.println("</form></tr>");
                        } else {
                            out.println("<tr>");
                            out.println("<td>" + s + "</td>");
                            out.println("<td>" + rs.getString("first_name") + "</td>");
                            out.println("<td>" + rs.getString("last_name") + "</td>");
                            out.println("<td>" + rs.getString("username") + "</td>");
                            out.println("<td><a href='manage_reps.jsp?edit_ssn=" + s + "'>Edit</a> | <a href='manage_reps.jsp?action=delete&ssn=" + s + "' onclick=\"return confirm('Are you sure?');\">Delete</a></td>");
                            out.println("</tr>");
                        }
                    }
                } catch(Exception e) { e.printStackTrace(); } finally {
                    if (rs != null) rs.close();
                    if (st != null) st.close();
                    if (con != null) con.close();
                }
            %>
        </table>

        <h3>Add New Representative</h3>
        <form action="manage_reps.jsp" method="POST">
            <input type="hidden" name="action" value="add">
            <table border="0">
                <tr><td>SSN:</td><td><input type="text" name="ssn" placeholder="9 digits" required maxlength="9"></td></tr>
                <tr><td>First Name:</td><td><input type="text" name="first_name" required></td></tr>
                <tr><td>Last Name:</td><td><input type="text" name="last_name" required></td></tr>
                <tr><td>Username:</td><td><input type="text" name="username" required></td></tr>
                <tr><td>Password:</td><td><input type="password" name="password" required></td></tr>
                <tr><td colspan="2"><input type="submit" value="Add Representative"></td></tr>
            </table>
        </form>
    </div>
</body>
</html>
