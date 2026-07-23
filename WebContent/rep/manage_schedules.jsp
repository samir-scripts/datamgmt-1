<%@ page import="java.sql.*" %>
<%@ page import="com.train.util.DatabaseConnection" %>
<%@ page session="true" %>
<%
    if (session.getAttribute("user") == null || !"customer_rep".equals(session.getAttribute("role"))) {
        response.sendRedirect("../login.jsp?error=Unauthorized access.");
        return;
    }
    
    String action = request.getParameter("action");
    if ("add".equals(action)) {
        String tId = request.getParameter("train_id");
        String lName = request.getParameter("line_name");
        String dDate = request.getParameter("departure_datetime");
        String aDate = request.getParameter("arrival_datetime");
        
        Connection con = null;
        PreparedStatement pst = null;
        try {
            con = DatabaseConnection.getConnection();
            // Note: date format expected YYYY-MM-DD HH:MM:SS
            String query = "INSERT INTO TRAIN_SCHEDULE (train_id, line_name, departure_datetime, arrival_datetime) VALUES (?, ?, ?, ?)";
            pst = con.prepareStatement(query);
            pst.setString(1, tId);
            pst.setString(2, lName);
            pst.setString(3, dDate);
            pst.setString(4, aDate);
            pst.executeUpdate();
            response.sendRedirect("manage_schedules.jsp?success=Schedule added.");
            return;
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("manage_schedules.jsp?error=Failed to add schedule.");
            return;
        } finally {
            if(pst != null) pst.close();
            if(con != null) con.close();
        }
    } else if ("edit".equals(action)) {
        String sId = request.getParameter("schedule_id");
        String dDate = request.getParameter("departure_datetime");
        String aDate = request.getParameter("arrival_datetime");
        
        Connection con = null;
        PreparedStatement pst = null;
        try {
            con = DatabaseConnection.getConnection();
            String query = "UPDATE TRAIN_SCHEDULE SET departure_datetime=?, arrival_datetime=? WHERE schedule_id=?";
            pst = con.prepareStatement(query);
            pst.setString(1, dDate);
            pst.setString(2, aDate);
            pst.setInt(3, Integer.parseInt(sId));
            pst.executeUpdate();
            response.sendRedirect("manage_schedules.jsp?success=Schedule updated.");
            return;
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("manage_schedules.jsp?error=Failed to update schedule.");
            return;
        } finally {
            if(pst != null) pst.close();
            if(con != null) con.close();
        }
    } else if ("delete".equals(action)) {
        String scheduleId = request.getParameter("id");
        Connection con = null;
        PreparedStatement pst = null;
        try {
            con = DatabaseConnection.getConnection();
            String query = "DELETE FROM TRAIN_SCHEDULE WHERE schedule_id = ?";
            pst = con.prepareStatement(query);
            pst.setInt(1, Integer.parseInt(scheduleId));
            pst.executeUpdate();
            response.sendRedirect("manage_schedules.jsp?success=Schedule deleted.");
            return;
        } catch(Exception e) {
            response.sendRedirect("manage_schedules.jsp?error=Failed to delete schedule.");
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
    <title>Manage Train Schedules</title>
</head>
<body>
    <div class="container">
        <div class="nav-links">
            <a href="rep_dashboard.jsp">&larr; Dashboard</a>
        </div>
        
        <h2>Manage Train Schedules</h2>
        <%
            String successMsg = request.getParameter("success");
            String errorMsg = request.getParameter("error");
            if (successMsg != null) out.println("<div><font color='green'>" + successMsg + "</font></div><br>");
            if (errorMsg != null) out.println("<div><font color='red'>" + errorMsg + "</font></div><br>");
            
            String editId = request.getParameter("edit_id");
        %>
        
        <table border="1" cellpadding="5" cellspacing="0">
            <tr><th>Schedule ID</th><th>Train ID</th><th>Transit Line</th><th>Departure</th><th>Arrival</th><th>Action</th></tr>
            <%
                Connection con = null;
                Statement st = null;
                ResultSet rs = null;
                try {
                    con = DatabaseConnection.getConnection();
                    st = con.createStatement();
                    rs = st.executeQuery("SELECT * FROM TRAIN_SCHEDULE");
                    while(rs.next()) {
                        String sId = rs.getString("schedule_id");
                        if (editId != null && editId.equals(sId)) {
                            out.println("<tr><form action='manage_schedules.jsp' method='POST'>");
                            out.println("<input type='hidden' name='action' value='edit'>");
                            out.println("<input type='hidden' name='schedule_id' value='" + sId + "'>");
                            out.println("<td>" + sId + "</td>");
                            out.println("<td>" + rs.getString("train_id") + "</td>");
                            out.println("<td>" + rs.getString("line_name") + "</td>");
                            // Truncate milliseconds for edit field if present
                            String dep = rs.getString("departure_datetime");
                            if (dep.endsWith(".0")) dep = dep.substring(0, dep.length()-2);
                            String arr = rs.getString("arrival_datetime");
                            if (arr.endsWith(".0")) arr = arr.substring(0, arr.length()-2);
                            
                            out.println("<td><input type='text' name='departure_datetime' value='" + dep + "'></td>");
                            out.println("<td><input type='text' name='arrival_datetime' value='" + arr + "'></td>");
                            out.println("<td><input type='submit' value='Save'> | <a href='manage_schedules.jsp'>Cancel</a></td>");
                            out.println("</form></tr>");
                        } else {
                            out.println("<tr>");
                            out.println("<td>" + sId + "</td>");
                            out.println("<td>" + rs.getString("train_id") + "</td>");
                            out.println("<td>" + rs.getString("line_name") + "</td>");
                            out.println("<td>" + rs.getString("departure_datetime") + "</td>");
                            out.println("<td>" + rs.getString("arrival_datetime") + "</td>");
                            out.println("<td><a href='manage_schedules.jsp?edit_id=" + sId + "'>Edit</a> | <a href='manage_schedules.jsp?action=delete&id=" + sId + "' onclick=\"return confirm('Delete this schedule and all its stops/reservations?');\">Delete</a></td>");
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
        
        <br>
        <h3>Add New Schedule</h3>
        <form action="manage_schedules.jsp" method="POST">
            <input type="hidden" name="action" value="add">
            <table border="0">
                <tr><td>Train ID:</td><td><input type="text" name="train_id" required></td></tr>
                <tr><td>Transit Line:</td><td><input type="text" name="line_name" required></td></tr>
                <tr><td>Departure Time:<br><small>(YYYY-MM-DD HH:MM:SS)</small></td><td><input type="text" name="departure_datetime" required></td></tr>
                <tr><td>Arrival Time:<br><small>(YYYY-MM-DD HH:MM:SS)</small></td><td><input type="text" name="arrival_datetime" required></td></tr>
                <tr><td colspan="2"><input type="submit" value="Add Schedule"></td></tr>
            </table>
        </form>
    </div>
</body>
</html>
