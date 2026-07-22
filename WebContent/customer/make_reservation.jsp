<%@ page import="java.sql.*" %>
<%@ page import="com.train.util.DatabaseConnection" %>
<%@ page session="true" %>
<%
    if (session.getAttribute("user") == null || !"customer".equals(session.getAttribute("role"))) {
        response.sendRedirect("../login.jsp?error=Unauthorized access.");
        return;
    }
    
    String scheduleId = request.getParameter("schedule_id");
    String originId = request.getParameter("origin");
    String destId = request.getParameter("dest");
    String travelDate = request.getParameter("date");
    
    if (scheduleId == null || originId == null || destId == null || travelDate == null) {
        response.sendRedirect("search_schedules.jsp?error=Missing reservation details.");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Make Reservation</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px; }
        .container { background-color: #fff; max-width: 600px; padding: 20px; border-radius: 5px; box-shadow: 0 0 10px rgba(0,0,0,0.1); margin: auto; }
        .form-group { margin-bottom: 15px; }
        label { display: block; margin-bottom: 5px; }
        select { width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 3px; }
        input[type="submit"] { background-color: #28a745; color: white; border: none; padding: 10px 20px; cursor: pointer; border-radius: 3px; }
        input[type="submit"]:hover { background-color: #218838; }
        .nav-links { margin-bottom: 20px; }
        .nav-links a { margin-right: 15px; text-decoration: none; color: #007bff; }
        .details { background-color: #e9ecef; padding: 10px; border-radius: 5px; margin-bottom: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="nav-links">
            <a href="search_schedules.jsp">&larr; Back to Search</a>
            <a href="../logout.jsp" style="float:right;">Logout</a>
        </div>
        <h2>Make a Reservation</h2>
        
        <%
            Connection con = null;
            PreparedStatement pst = null;
            ResultSet rs = null;
            int baseFare = 0;
            String trainId = "";
            String lineName = "";
            
            try {
                con = DatabaseConnection.getConnection();
                String query = "SELECT ts.train_id, ts.line_name, tl.base_fare " +
                               "FROM TRAIN_SCHEDULE ts " +
                               "JOIN TRANSIT_LINE tl ON ts.line_name = tl.line_name " +
                               "WHERE ts.schedule_id = ?";
                pst = con.prepareStatement(query);
                pst.setInt(1, Integer.parseInt(scheduleId));
                rs = pst.executeQuery();
                
                if (rs.next()) {
                    baseFare = rs.getInt("base_fare");
                    trainId = rs.getString("train_id");
                    lineName = rs.getString("line_name");
                }
            } catch(Exception e) {
                e.printStackTrace();
            } finally {
                if(rs != null) rs.close();
                if(pst != null) pst.close();
                if(con != null) con.close();
            }
        %>
        
        <div class="details">
            <p><strong>Train ID:</strong> <%= trainId %></p>
            <p><strong>Transit Line:</strong> <%= lineName %></p>
            <p><strong>Travel Date:</strong> <%= travelDate %></p>
            <p><strong>Base Fare:</strong> $<%= baseFare %></p>
        </div>
        
        <form action="process_reservation.jsp" method="POST">
            <input type="hidden" name="schedule_id" value="<%= scheduleId %>">
            <input type="hidden" name="origin_station_id" value="<%= originId %>">
            <input type="hidden" name="destination_station_id" value="<%= destId %>">
            <input type="hidden" name="reservation_date" value="<%= travelDate %>">
            <input type="hidden" name="base_fare" value="<%= baseFare %>">
            
            <div class="form-group">
                <label for="trip_type">Trip Type:</label>
                <select name="trip_type" id="trip_type" required>
                    <option value="one-way">One-Way</option>
                    <option value="round-trip">Round-Trip</option>
                </select>
            </div>
            
            <div class="form-group">
                <label for="passenger_type">Passenger Type (Select for discounts):</label>
                <select name="passenger_type" id="passenger_type" required>
                    <option value="adult">Adult (No discount)</option>
                    <option value="child">Child (25% off)</option>
                    <option value="senior">Senior (35% off)</option>
                    <option value="disabled">Disabled (50% off)</option>
                </select>
            </div>
            
            <input type="submit" value="Confirm Booking">
        </form>
    </div>
</body>
</html>
