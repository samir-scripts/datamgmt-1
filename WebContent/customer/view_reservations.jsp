<%@ page import="java.sql.*" %>
<%@ page import="com.train.util.DatabaseConnection" %>
<%@ page session="true" %>
<%
    if (session.getAttribute("user") == null || !"customer".equals(session.getAttribute("role"))) {
        response.sendRedirect("../login.jsp?error=Unauthorized access.");
        return;
    }
    int cid = (Integer) session.getAttribute("userId");
%>
<!DOCTYPE html>
<html>
<head>
    <title>My Reservations</title>
    
</head>
<body>
    <div class="container">
        <div class="nav-links">
            <a href="customer_dashboard.jsp">&larr; Back to Dashboard</a>
            <a href="../logout.jsp" style="float:right;">Logout</a>
        </div>
        
        <%
            String successMsg = request.getParameter("success");
            if (successMsg != null) {
                out.println("<div class='success'>" + successMsg + "</div>");
            }
        %>
        
        <h2>Current (Upcoming) Reservations</h2>
        <table>
            <tr>
                <th>Res. #</th><th>Date</th><th>Train</th><th>Origin</th><th>Destination</th><th>Trip Type</th><th>Fare</th><th>Status</th><th>Action</th>
            </tr>
            <%
                Connection con = null;
                PreparedStatement pstCurrent = null;
                PreparedStatement pstPast = null;
                ResultSet rsCurrent = null;
                ResultSet rsPast = null;
                
                try {
                    con = DatabaseConnection.getConnection();
                    String query = "SELECT r.reservation_number, r.reservation_date, r.trip_type, r.total_fare, r.status, " +
                                   "ts.train_id, o.name as origin_name, d.name as dest_name " +
                                   "FROM RESERVATION r " +
                                   "JOIN TRAIN_SCHEDULE ts ON r.schedule_id = ts.schedule_id " +
                                   "JOIN STATION o ON r.origin_station_id = o.station_id " +
                                   "JOIN STATION d ON r.destination_station_id = d.station_id " +
                                   "WHERE r.cid = ? AND r.reservation_date >= CURDATE() " +
                                   "ORDER BY r.reservation_date ASC";
                    pstCurrent = con.prepareStatement(query);
                    pstCurrent.setInt(1, cid);
                    rsCurrent = pstCurrent.executeQuery();
                    
                    boolean foundCurrent = false;
                    while(rsCurrent.next()) {
                        foundCurrent = true;
                        out.println("<tr>");
                        out.println("<td>" + rsCurrent.getInt("reservation_number") + "</td>");
                        out.println("<td>" + rsCurrent.getString("reservation_date") + "</td>");
                        out.println("<td>" + rsCurrent.getString("train_id") + "</td>");
                        out.println("<td>" + rsCurrent.getString("origin_name") + "</td>");
                        out.println("<td>" + rsCurrent.getString("dest_name") + "</td>");
                        out.println("<td>" + rsCurrent.getString("trip_type") + "</td>");
                        out.println("<td>$" + rsCurrent.getInt("total_fare") + "</td>");
                        out.println("<td>" + rsCurrent.getString("status") + "</td>");
                        if ("confirmed".equals(rsCurrent.getString("status"))) {
                            out.println("<td><a href='cancel_reservation.jsp?id=" + rsCurrent.getInt("reservation_number") + "' class='cancel-btn' onclick=\"return confirm('Are you sure you want to cancel this reservation?');\">Cancel</a></td>");
                        } else {
                            out.println("<td>-</td>");
                        }
                        out.println("</tr>");
                    }
                    if (!foundCurrent) out.println("<tr><td colspan='9'>No upcoming reservations.</td></tr>");
                    
                } catch(Exception e) { e.printStackTrace(); }
            %>
        </table>

        <h2>Past Reservations</h2>
        <table>
            <tr>
                <th>Res. #</th><th>Date</th><th>Train</th><th>Origin</th><th>Destination</th><th>Trip Type</th><th>Fare</th><th>Status</th>
            </tr>
            <%
                try {
                    String pastQuery = "SELECT r.reservation_number, r.reservation_date, r.trip_type, r.total_fare, r.status, " +
                                       "ts.train_id, o.name as origin_name, d.name as dest_name " +
                                       "FROM RESERVATION r " +
                                       "JOIN TRAIN_SCHEDULE ts ON r.schedule_id = ts.schedule_id " +
                                       "JOIN STATION o ON r.origin_station_id = o.station_id " +
                                       "JOIN STATION d ON r.destination_station_id = d.station_id " +
                                       "WHERE r.cid = ? AND r.reservation_date < CURDATE() " +
                                       "ORDER BY r.reservation_date DESC";
                    pstPast = con.prepareStatement(pastQuery);
                    pstPast.setInt(1, cid);
                    rsPast = pstPast.executeQuery();
                    
                    boolean foundPast = false;
                    while(rsPast.next()) {
                        foundPast = true;
                        out.println("<tr>");
                        out.println("<td>" + rsPast.getInt("reservation_number") + "</td>");
                        out.println("<td>" + rsPast.getString("reservation_date") + "</td>");
                        out.println("<td>" + rsPast.getString("train_id") + "</td>");
                        out.println("<td>" + rsPast.getString("origin_name") + "</td>");
                        out.println("<td>" + rsPast.getString("dest_name") + "</td>");
                        out.println("<td>" + rsPast.getString("trip_type") + "</td>");
                        out.println("<td>$" + rsPast.getInt("total_fare") + "</td>");
                        out.println("<td>" + rsPast.getString("status") + "</td>");
                        out.println("</tr>");
                    }
                    if (!foundPast) out.println("<tr><td colspan='8'>No past reservations.</td></tr>");
                    
                } catch(Exception e) { e.printStackTrace(); } finally {
                    if (rsCurrent != null) rsCurrent.close();
                    if (rsPast != null) rsPast.close();
                    if (pstCurrent != null) pstCurrent.close();
                    if (pstPast != null) pstPast.close();
                    if (con != null) con.close();
                }
            %>
        </table>
    </div>
</body>
</html>
