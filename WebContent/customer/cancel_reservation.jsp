<%@ page import="java.sql.*" %>
<%@ page import="com.train.util.DatabaseConnection" %>
<%@ page session="true" %>
<%
    if (session.getAttribute("user") == null || !"customer".equals(session.getAttribute("role"))) {
        response.sendRedirect("../login.jsp?error=Unauthorized access.");
        return;
    }
    
    int cid = (Integer) session.getAttribute("userId");
    String resIdStr = request.getParameter("id");
    
    if (resIdStr != null && !resIdStr.isEmpty()) {
        Connection con = null;
        PreparedStatement pst = null;
        try {
            con = DatabaseConnection.getConnection();
            String query = "UPDATE RESERVATION SET status = 'cancelled' WHERE reservation_number = ? AND cid = ?";
            pst = con.prepareStatement(query);
            pst.setInt(1, Integer.parseInt(resIdStr));
            pst.setInt(2, cid);
            
            pst.executeUpdate();
            
            response.sendRedirect("view_reservations.jsp?success=Reservation cancelled.");
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("view_reservations.jsp?error=Failed to cancel reservation.");
        } finally {
            if(pst != null) pst.close();
            if(con != null) con.close();
        }
    } else {
        response.sendRedirect("view_reservations.jsp");
    }
%>
