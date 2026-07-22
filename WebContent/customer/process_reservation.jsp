<%@ page import="java.sql.*" %>
<%@ page import="com.train.util.DatabaseConnection" %>
<%@ page session="true" %>
<%
    if (session.getAttribute("user") == null || !"customer".equals(session.getAttribute("role"))) {
        response.sendRedirect("../login.jsp?error=Unauthorized access.");
        return;
    }
    
    int cid = (Integer) session.getAttribute("userId");
    int scheduleId = Integer.parseInt(request.getParameter("schedule_id"));
    int originId = Integer.parseInt(request.getParameter("origin_station_id"));
    int destId = Integer.parseInt(request.getParameter("destination_station_id"));
    String reservationDate = request.getParameter("reservation_date");
    int baseFare = Integer.parseInt(request.getParameter("base_fare"));
    String tripType = request.getParameter("trip_type");
    String passengerType = request.getParameter("passenger_type");
    
    // Calculate total fare
    double fareMultiplier = 1.0;
    if ("round-trip".equals(tripType)) {
        fareMultiplier = 2.0;
    }
    
    double discount = 0.0;
    if ("child".equals(passengerType)) {
        discount = 0.25;
    } else if ("senior".equals(passengerType)) {
        discount = 0.35;
    } else if ("disabled".equals(passengerType)) {
        discount = 0.50;
    }
    
    int totalFare = (int) Math.round(baseFare * fareMultiplier * (1.0 - discount));
    
    Connection con = null;
    PreparedStatement pst = null;
    
    try {
        con = DatabaseConnection.getConnection();
        String insertQuery = "INSERT INTO RESERVATION (cid, schedule_id, origin_station_id, destination_station_id, reservation_date, trip_type, passenger_type, total_fare, status) " +
                             "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'confirmed')";
        pst = con.prepareStatement(insertQuery);
        pst.setInt(1, cid);
        pst.setInt(2, scheduleId);
        pst.setInt(3, originId);
        pst.setInt(4, destId);
        pst.setDate(5, java.sql.Date.valueOf(reservationDate));
        pst.setString(6, tripType);
        pst.setString(7, passengerType);
        pst.setInt(8, totalFare);
        
        pst.executeUpdate();
        
        response.sendRedirect("view_reservations.jsp?success=Reservation confirmed successfully!");
    } catch(Exception e) {
        e.printStackTrace();
        response.sendRedirect("search_schedules.jsp?error=Failed to process reservation.");
    } finally {
        if(pst != null) pst.close();
        if(con != null) con.close();
    }
%>
