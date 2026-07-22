<%@ page import="java.sql.*" %>
<%@ page import="com.train.util.DatabaseConnection" %>
<%
    String firstName = request.getParameter("first_name");
    String lastName = request.getParameter("last_name");
    String email = request.getParameter("email");
    String username = request.getParameter("username");
    String password = request.getParameter("password");

    if(firstName == null || lastName == null || email == null || username == null || password == null ||
       firstName.trim().isEmpty() || lastName.trim().isEmpty() || email.trim().isEmpty() || username.trim().isEmpty() || password.trim().isEmpty()) {
        response.sendRedirect("register.jsp?error=All fields are required.");
        return;
    }

    Connection con = null;
    PreparedStatement pstCheck = null;
    PreparedStatement pstInsert = null;
    ResultSet rsCheck = null;

    try {
        con = DatabaseConnection.getConnection();

        // Check if username already exists in CUSTOMER or EMPLOYEE
        String checkQuery = "SELECT username FROM CUSTOMER WHERE username = ? UNION SELECT username FROM EMPLOYEE WHERE username = ?";
        pstCheck = con.prepareStatement(checkQuery);
        pstCheck.setString(1, username);
        pstCheck.setString(2, username);
        rsCheck = pstCheck.executeQuery();

        if(rsCheck.next()) {
            response.sendRedirect("register.jsp?error=Username already exists. Please choose another.");
            return;
        }

        // Insert new customer
        String insertQuery = "INSERT INTO CUSTOMER (first_name, last_name, email, username, password) VALUES (?, ?, ?, ?, ?)";
        pstInsert = con.prepareStatement(insertQuery);
        pstInsert.setString(1, firstName);
        pstInsert.setString(2, lastName);
        pstInsert.setString(3, email);
        pstInsert.setString(4, username);
        pstInsert.setString(5, password);

        int rows = pstInsert.executeUpdate();
        if(rows > 0) {
            response.sendRedirect("login.jsp?error=Registration successful! Please login."); // Reusing error div for success message (hacky but works for now, or could pass a success param)
        } else {
            response.sendRedirect("register.jsp?error=Registration failed. Try again.");
        }

    } catch(Exception e) {
        e.printStackTrace();
        response.sendRedirect("register.jsp?error=Database error occurred.");
    } finally {
        if(rsCheck != null) rsCheck.close();
        if(pstCheck != null) pstCheck.close();
        if(pstInsert != null) pstInsert.close();
        if(con != null) con.close();
    }
%>
