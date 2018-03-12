/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.akiresoft.marquee;

import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.util.Enumeration;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author Erika
 */
public class MarqueeServlet extends HttpServlet {
    String settingsFileName = null;
    final static Logger myLogger = Logger.getLogger(MarqueeServlet.class.getName());
   
    /** 
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code> methods.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        // What action is coming in?
        String action = request.getParameter("action");
        
        switch (action) {
            case "POSITION_UPDATE":
                updateProperties("POSITION_", request);

                break;
            case "FLAG_UPDATE":
                updateProperties("DISPLAY_FLAG", request);
                
                break;
            case "LAP_UPDATE":
                updateProperties("CURRENT_LAP", request);
                
                break;
            default:
        }
    }
    
    private void updateProperties(String prefix, HttpServletRequest request) {
        try {
            Properties marqueeProps = new Properties();
            marqueeProps.load(new FileInputStream(settingsFileName));

            // Update the properties.
            for (Enumeration<String> allNames = request.getParameterNames(); allNames.hasMoreElements();) {
                String currName = allNames.nextElement();
                if (currName.startsWith(prefix))
                    marqueeProps.setProperty(currName, request.getParameter(currName));
            }

            // Save the properties back out.
            marqueeProps.store(new FileWriter(settingsFileName), "Valid flags: green.gif, yellow.gif, white.gif, red.gif, black.gif, blackx.gif, moveover.gif, checkered.gif");
        } catch (IOException ex) {
            myLogger.log(Level.SEVERE, null, ex);
        }

    }
    @Override
    public void init() throws ServletException {
        super.init(); //To change body of generated methods, choose Tools | Templates.
        settingsFileName = this.getServletContext().getInitParameter("settingsFile");
        myLogger.log(Level.ALL, "The settingsFileName is: {0}", settingsFileName);
        
        // Let's write a file so we know where to put our settingsFile.
        InputStream is = null;
        try {
            is = new FileInputStream(settingsFileName);
            
            myLogger.log(Level.INFO, "I have found my settings file.");
        }
        catch (Exception ex) {
            myLogger.log(Level.SEVERE, "An error occurred opening my settings file", ex);
            myLogger.log(Level.SEVERE, "Will now create settingsLocationHelp.txt");
            FileWriter fw = null;
            try {
                fw = new FileWriter("settingsLocationHelp.txt");
                fw.write("This is where my setting file should be");
            }
            catch (Exception e)
            {
                myLogger.log(Level.SEVERE, "Couldn't create the settingsLocationHelp.txt file", e);
            }
            finally {
                if (fw != null) {
                    try {
                        fw.close();
                    }
                    catch (Exception e2) {
                        // Do nothing.
                    }
                }
            }
        }
        finally {
            if (is != null) {
                try {
                    is.close();
                }
                catch (Exception e) {
                    // Do nothing.
                }
            }
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /** 
     * Handles the HTTP <code>GET</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        processRequest(request, response);
    } 

    /** 
     * Handles the HTTP <code>POST</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        processRequest(request, response);
    }

    /** 
     * Returns a short description of the servlet.
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
