<%@ page import="java.sql.*" %>
<%@ page import="com.train.util.DatabaseConnection" %>
<%@ page session="true" %>
<%
    if (session.getAttribute("user") == null || !"customer_rep".equals(session.getAttribute("role"))) {
        response.sendRedirect("../login.jsp?error=Unauthorized access.");
        return;
    }
    
    String repSsn = (String) session.getAttribute("userId");
    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String answer = request.getParameter("answer");
        String qId = request.getParameter("question_id");
        if (answer != null && !answer.trim().isEmpty() && qId != null) {
            Connection con = null;
            PreparedStatement pst = null;
            try {
                con = DatabaseConnection.getConnection();
                String query = "UPDATE CUSTOMER_QUESTION SET answer_text = ?, employee_ssn = ?, answer_datetime = NOW() WHERE question_id = ?";
                pst = con.prepareStatement(query);
                pst.setString(1, answer);
                pst.setString(2, repSsn);
                pst.setInt(3, Integer.parseInt(qId));
                pst.executeUpdate();
                response.sendRedirect("customer_questions.jsp?success=Reply sent successfully.");
                return;
            } catch(Exception e) {
                e.printStackTrace();
                response.sendRedirect("customer_questions.jsp?error=Failed to send reply.");
                return;
            } finally {
                if(pst != null) pst.close();
                if(con != null) con.close();
            }
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Customer Questions</title>
    
</head>
<body>
    <div class="container">
        <div class="nav-links">
            <a href="rep_dashboard.jsp">&larr; Dashboard</a>
        </div>
        
        <h2>Customer Questions</h2>
        <%
            String successMsg = request.getParameter("success");
            String errorMsg = request.getParameter("error");
            if (successMsg != null) out.println("<div class='success'>" + successMsg + "</div>");
            if (errorMsg != null) out.println("<div class='error'>" + errorMsg + "</div>");
        %>
        
        <div class="search-bar">
            <form action="customer_questions.jsp" method="GET">
                <input type="text" name="keyword" placeholder="Search by keyword..." value="<%= request.getParameter("keyword") != null ? request.getParameter("keyword") : "" %>">
                <input type="submit" value="Search">
                <a href="customer_questions.jsp" style="margin-left: 10px;">Clear</a>
            </form>
        </div>

        <%
            String keyword = request.getParameter("keyword");
            Connection con = null;
            PreparedStatement pst = null;
            ResultSet rs = null;
            try {
                con = DatabaseConnection.getConnection();
                String query = "SELECT cq.question_id, cq.question_text, cq.answer_text, cq.question_datetime, c.first_name, c.last_name " +
                               "FROM CUSTOMER_QUESTION cq " +
                               "JOIN CUSTOMER c ON cq.cid = c.cid ";
                
                if (keyword != null && !keyword.trim().isEmpty()) {
                    query += "WHERE cq.question_text LIKE ? ";
                }
                query += "ORDER BY cq.question_datetime DESC";
                
                pst = con.prepareStatement(query);
                if (keyword != null && !keyword.trim().isEmpty()) {
                    pst.setString(1, "%" + keyword + "%");
                }
                
                rs = pst.executeQuery();
                boolean found = false;
                while(rs.next()) {
                    found = true;
                    out.println("<div class='qna'>");
                    out.println("<strong>Customer " + rs.getString("first_name") + " " + rs.getString("last_name") + " asked:</strong><br>");
                    out.println("<em>" + rs.getString("question_text") + "</em> <span style='font-size: 0.8em; color: #666;'>(" + rs.getString("question_datetime") + ")</span>");
                    
                    if (rs.getString("answer_text") != null) {
                        out.println("<div class='answer'><strong>Answer:</strong> " + rs.getString("answer_text") + "</div>");
                    } else {
                        // Display reply form
                        out.println("<div class='answer'>");
                        out.println("<form action='customer_questions.jsp' method='POST'>");
                        out.println("<input type='hidden' name='question_id' value='" + rs.getInt("question_id") + "'>");
                        out.println("<textarea name='answer' rows='2' placeholder='Write a reply...' required></textarea><br>");
                        out.println("<input type='submit' value='Reply'>");
                        out.println("</form>");
                        out.println("</div>");
                    }
                    out.println("</div>");
                }
                if (!found) {
                    out.println("<p>No questions found.</p>");
                }
            } catch(Exception e) { e.printStackTrace(); } finally {
                if (rs != null) rs.close();
                if (pst != null) pst.close();
                if (con != null) con.close();
            }
        %>
    </div>
</body>
</html>
