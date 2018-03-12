<%--
    Document   : index
    Created on : Oct 2, 2012, 5:39:29 PM
    Author     : Jim
--%>

<%@page import="java.io.FileInputStream"%>
<%@page import="java.io.File"%>
<%@page import="java.io.FileReader"%>
<%@page import="java.util.Properties"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Properties marqueeProps = new Properties();
    String settingsFileName = this.getServletContext().getInitParameter("settingsFile");
    //marqueeProps.load(getServletContext().getResourceAsStream(settingsFileName));
    marqueeProps.load(new FileInputStream(settingsFileName));

    // OK, first let's get the number of drivers
    int numberOfDrivers = Integer.parseInt(marqueeProps.getProperty("NUMBER_OF_DRIVERS"));
    String imageDir = marqueeProps.getProperty("IMAGE_DIR");
    String flagDir = marqueeProps.getProperty("FLAG_DIR");
    String[] driverNames = new String[numberOfDrivers];
    int[] racePosition = new int[numberOfDrivers];

    // Get the lap info
    String currentLap = marqueeProps.getProperty("CURRENT_LAP", "0");
    int lastLap = Integer.parseInt(marqueeProps.getProperty("LAST_LAP", "0"));

    // Get the flag to display.
    String flag = marqueeProps.getProperty("DISPLAY_FLAG");

    // Get the Marquee Delay Time in milliseconds.
    int marqueeDelay = Integer.parseInt(marqueeProps.getProperty("MARQUEE_DELAY_MS", "25"));
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
<html>
    <head>
        <meta http-equiv="Content-type" content="text/html;charset=UTF-8" />
        <script language="Javascript">
            var DavidsMarquee;
            var DavidsMarqueePos;
            var MarqueeDelayTime;
            var LeadChangeDiv;
            var intervalVal;
            var leadChangeInterval = -1;
            var marqueeTable;
            var marqueeRow;
            var marqueeDivWidth;
            var marqueeWidth;
            var marqueeRestartWidth;
            var numberOfDrivers = <%=numberOfDrivers%>;

            function Driver(driverInfo)
            {
                this.driverName = driverInfo[0];
                this.driverFullName = driverInfo[1];
                this.driverImage = driverInfo[2];
                this.driverStatus = driverInfo[3];
            }

            var drivers = new Array(numberOfDrivers);
            var racePosition = new Array(numberOfDrivers);
            var raceLeader = -1;

            function init()
            {
                // Put the lead change table at the same position as the Lap Table.
                LeadChangeDiv = document.getElementById('LeadChangeDiv');
                var lt = document.getElementById('LapTable');
                var lc = document.getElementById('leaderCell');
                LeadChangeDiv.style.left = (lt.offsetLeft + lc.offsetLeft) + 'px';
                LeadChangeDiv.style.top = (lt.offsetTop + lc.offsetTop) + 'px';
                LeadChangeDiv.style.width = lc.offsetWidth + 'px';

                marqueeDivWidth = document.getElementById('MarqueeDiv').clientWidth;
                DavidsMarqueePos = 0;
                DavidsMarquee = document.getElementById('MarqueeTable');

                marqueeTable = document.getElementById('MarqueeTable');

                // Initialize our Driver Objects and racePosition arrays
            <%
                for (int i = 0; i < numberOfDrivers; i++)
                {
                    String driverInfo = marqueeProps.getProperty("DRIVER_" + i);
                    driverNames[i] = driverInfo.substring(0, driverInfo.indexOf("|"));
                    racePosition[i] = Integer.parseInt(marqueeProps.getProperty("POSITION_" + i));
                    // driverInfo is made up of:
                    //   <NAME>|<FULLNAME>|<IMAGE FILE NAME>|CHASE STATUS
            %>
                var driverInfo = new String('<%=driverInfo%>');
                drivers[<%=i%>] = new Driver(driverInfo.split('|'));
                racePosition[<%=i%>] = '<%=racePosition[i]%>';
            <%
                }
            %>

                buildMarquee();

                // Now set up the marquee scroll.
                intervalVal = setInterval(doMove, <%=marqueeDelay%>);
            }

            function buildMarquee()
            {
//                marqueeRow = document.getElementById('MarqueeRow');
                marqueeRow = marqueeTable.insertRow(-1);

                // Hide this row if one already exists
                var isInitialRow = (marqueeRow.rowIndex == 0);
                if (!isInitialRow)
                    marqueeRow.style.visibility = 'collapse';

                // Insert the first copy of the Marquee
                addMarqueeCopy();

                // Now duplicate the entries until they are wide enough to allow
                // the scroll to go far enough that the first entry is ready
                // to
                if (isInitialRow)
                {
                    marqueeWidth = marqueeRow.clientWidth;
                    marqueeRestartWidth = marqueeWidth-1;
                }

                // Now add a second copy, because at a minimum we need two copies to
                // ensure the Marquee is continuous.
                addMarqueeCopy();

                // Now calculate if we need more than two copies.
                if (marqueeWidth <= marqueeDivWidth)
                {
                    var marqueeCopies;
                    for (marqueeCopies = 2; (marqueeCopies * marqueeWidth) < (marqueeDivWidth + marqueeWidth); marqueeCopies++)
                        addMarqueeCopy();
                }

                // Set the Race Leader.
                if (raceLeader != racePosition[0])
                {
                    var showChange = (raceLeader != -1);
                    raceLeader = racePosition[0];
                    document.getElementById('leaderNameSpan').innerHTML = '<img src="<%=imageDir%>/' + drivers[racePosition[0]].driverImage + '" height="16" width="12">' + drivers[racePosition[0]].driverFullName;

                    if (showChange)
                    {
                        // First set the Race Leader name.
                        showLeaderChange();
                    }
                }

                if (!isInitialRow)
                {
                    marqueeTable.deleteRow(0);
                    marqueeRow.style.visibility = 'visible';
                }
            }

            function addMarqueeCopy()
            {
                var i;
                for (i = 0; i < numberOfDrivers; i++)
                {
                    insertCar(i);
                }
            }
            function doMove()
            {
                if (DavidsMarqueePos < -(marqueeWidth-1))
                    DavidsMarqueePos = 0;
                else
                    DavidsMarqueePos--;
                DavidsMarquee.style.left = DavidsMarqueePos + 'px';
            }
            function changeInterval()
            {
                clearInterval(intervalVal);
                intervalVal = setInterval(doMove, iv.value);
            }
            function insertCar(carPosition)
            {
                // First, let's add two Cells, one for a black divider, and
                // the other to hold the position of this car
                var posCell = marqueeRow.insertCell(marqueeRow.cells.length);
                posCell.appendChild(document.createTextNode(''));
                posCell.innerHTML = '&nbsp;';
                posCell.style.backgroundColor = 'black';
                posCell.style.borderWidth = '1px';
                posCell.style.borderColor = 'black';
                posCell.style.borderStyle = 'inset';
                posCell.style.whiteSpace = 'pre';
                posCell.style.width = '8px';

                // Insert the Cars Position.
                posCell = marqueeRow.insertCell(marqueeRow.cells.length);
                posCell.appendChild(document.createTextNode(''));
                posCell.innerHTML = '&nbsp' + (carPosition+1) + '&nbsp;';
                posCell.style.fontSize = '26px';

                var currDriver = drivers[racePosition[carPosition]];
                // Create a new Cell in the Marquee that will hold a Driver Table, which
                // has one row with two cells of its own - an Image and the Driver Name.
                var newCell = marqueeRow.insertCell(marqueeRow.cells.length);

                // Create the Driver Table
                var carTable = document.createElement('table');
                carTable.cellPadding = 0;
                carTable.cellSpacing = 0;
                carTable.border = 0;

                // Add a table row.
                var carRow = carTable.insertRow(0);
                // Add the image cell to the row.
                var tableCell = carRow.insertCell(0);
                var carImage = document.createElement('img');
                carImage.src = '<%=imageDir%>/' + currDriver.driverImage;
                carImage.height = 32;
                carImage.width = 24;
                tableCell.appendChild(carImage);
                // Now add the Driver Name cell to the row.
                tableCell = carRow.insertCell(1);
                tableCell.innerHTML = '&nbsp;' + currDriver.driverName + '&nbsp';
                tableCell.style.verticalAlign = 'middle';
                tableCell.style.whiteSpace = 'nowrap';
                tableCell.style.fontSize = '26px';

                // Add the table to the marquee
                newCell.appendChild(carTable);

                if (currDriver.driverStatus == 'IN')
                {
                    posCell.style.backgroundColor = '#FFFF00';
                    posCell.style.color = '#000000';
                    newCell.style.backgroundColor = '#FFFF00';
                    newCell.style.color = "#000000";
                }
                else if (currDriver.driverStatus == 'WILDCARD')
                {
                    posCell.style.backgroundColor = '#00FF00';
                    posCell.style.color = '#000000';
                    newCell.style.backgroundColor = '#00FF00';
                    newCell.style.color = "#000000";
                }
                else if (currDriver.driverStatus == 'LEADER')
                {
                    posCell.style.backgroundColor = '#0000FF';
                    posCell.style.color = '#FFFFFF';
                    newCell.style.backgroundColor = '#0000FF';
                    newCell.style.color = "#FFFFFF";
                }
                else // Assume = NOT_IN
                {
                    posCell.style.backgroundColor = '#000000';
                    posCell.style.color = '#FFFF00';
                    newCell.style.backgroundColor = '#000000';
                    newCell.style.color = "#FFFFFF";
                }
            }

            function driverChange(evt)
            {
                // One of the driver position drop downs has changed value.  The number at the
                // end of the control name indicates that position.  The names are "position_XX".
                var changedPosition = evt.target.id.slice(9);

                // First step is to find the original position of the driver
                // the drop down was changed to.
                var driverChangedTo = evt.target.value;
                var driverChangedFrom = racePosition[changedPosition];

                // Now swap changedFrom driver into the old spot of changedTo driver.
                var swapPosition;
                for (swapPosition = 0; racePosition[swapPosition] != driverChangedTo; swapPosition++);

                var swapSelect = document.getElementById('position_' + swapPosition);
                swapSelect.options[driverChangedFrom].selected = true;
                swapSelect.options[driverChangedTo].selected = false;
                racePosition[changedPosition] = driverChangedTo;
                racePosition[swapPosition] = driverChangedFrom;

                // Now update the marquee.
                buildMarquee();
                
                document.poleForm.action.value = 'POSITION_UPDATE';
                document.poleForm.submit();
                return false;
            }
            function showLeaderChange()
            {
//                theOpacity = 1;
//                LeadChangeDiv.style.opacity = theOpacity;
//                LeadChangeDiv.style.visibility = 'visible';
                if (leadChangeInterval != -1)
                {
                    clearInterval(leadChangeInterval);
                    leadChangeInterval = -1;
                }
                document.getElementById('leaderTitleSpan').innerHTML = 'Lead Change ';
                leadChangeInterval = setInterval(fadeLeaderChange, 10000);
            }
            function fadeLeaderChange()
            {
//                theOpacity -= .01;
//                LeadChangeDiv.style.opacity = theOpacity;
//                if (theOpacity < 0)
//                {
                    clearInterval(leadChangeInterval);
                    leadChangeInterval = -1;
                    document.getElementById('leaderTitleSpan').innerHTML = 'Leader: ';
//                }
            }
            
            function setFlag(src, flag_value) {
                alert('I am in setFlag. src = ' + src + ', and flag_value = ' + flag_value);
                alert('Hi');
                alert('Current src of the flagImage is ' + document.getElementById('flagImage').src);
                document.getElementById('flagImage').src = src;
                document.poleForm.DISPLAY_FLAG.value = flag_value;
                document.poleForm.action.value = 'FLAG_UPDATE';
                document.poleForm.submit();
                alert('Leaving setFlag and flagImage has a src of ' + document.flagImage.src);
            }
        </script>
        <meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
        <title>Davids Marquee</title>
    </head>
    <body onload="init();" style="background-color: #262525; max-height: 100%"><!-- style="margin: 0px;" -->
        <iframe id="hiddenFrame" name="hiddenFrame" style="display: none"></iframe>
        <form name="poleForm" method="post" action="/TestWebApp/MarqueeServlet" target="hiddenFrame">
            <input type="hidden" name="action"><input type="hidden" name="DISPLAY_FLAG">
        <table id="LapTable" border="0" cellpadding="0" cellspacing="0" width="100%" bgcolor="#000000">
            <tr>
                <td width="50%" align="right" style="color: #FFFFFF; font-weight: bold;"><img id="flagImage" src="<%=flagDir%>/<%=flag%>" border="1" style="height: 13px"> <input type="text" size="16" name="CURRENT_LAP" value="<%=currentLap%>" style="border: 0px; background-color: #000000; color: #FFFF00" onblur="this.style.backgroundColor='#000000'; this.style.color='#FFFF00';" onfocus="this.style.backgroundColor='#FFFFFF'; this.style.color='#000000';" onchange="document.poleForm.action.value='LAP_UPDATE'; document.poleForm.submit();"></td><td id="leaderCell" width="50%" align="left"><span id="leaderTitleSpan" style="color: #FFFF00">Leader: </span><span id="leaderNameSpan" style="color: #FFFFFF; font-weight: bold"></span></td>
            </tr>
        </table>
            <div id="LeadChangeDiv" style="position: absolute; visibility: hidden; z-index: 1; width: 100%">
            <table id="LeadChangeTable" border="0" cellpadding="0" cellspacing="0" width="100%" bgcolor="#000000" >
                <tr>
                    <td width="100%" align="left" style="color: #FFFF00; font-weight: bold;">&lt;&lt; LEAD CHANGE &gt;&gt;</td>
                </tr>
            </table>
        </div>
        <div id="MarqueeDiv" style="margin: 0px; overflow: hidden; width: 100%; border-top-color: gold; border-top-style: ridge; border-bottom-style: ridge; border-bottom-color: gold;">
            <table id="MarqueeTable" style="position:relative; left:0; margin: 0px;" border="0" cellpadding="0" cellspacing="0">
            </table>
        </div>

        <table border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr>
                <td width="50%">&nbsp;</td>
                <td id="poleDivCell">
                    <div id="poleDiv" align="center" style="height: 600px;overflow: auto; width: 171px">
                            <table border="1" cellpadding="0" cellspacing="0">
                                <%
                                for (int i = 0; i < numberOfDrivers; i++)
                                {
                                %>
                                <tr>
                                    <td style="color: red"><%=i+1%></td>
                                    <td>
                                        <select name="POSITION_<%=i%>" id="position_<%=i%>" size="1" onchange="driverChange(event);">
                                            <%
                                            for (int j = 0; j < numberOfDrivers; j++)
                                            {
                                            %>
                                            <option value="<%=j%>"<%=racePosition[i]==j? " selected" : ""%>><%=driverNames[j]%></option>
                                            <%
                                            }
                                            %>
                                        </select>
                                    </td>
                                </tr>
                                <%
                                }
                                %>
                            </table>
                    </div>
                </td>
                <td width="50%">&nbsp;</td>
            </tr>
        </table>
        </form>
        <div id="flagPicker" style="bottom: 0px; position: relative; left: 0px">
            <img src="<%=flagDir%>/green.gif" style="height: 13px" onclick="setFlag(this.src, 'green.gif');">
            <img src="<%=flagDir%>/yellow.gif" style="height: 13px" onclick="setFlag(this.src, 'yellow.gif');">
            <img src="<%=flagDir%>/white.gif" style="height: 13px" onclick="setFlag(this.src, 'white.gif');">
            <img src="<%=flagDir%>/red.gif" style="height: 13px" onclick="setFlag(this.src, 'red.gif');">
            <img src="<%=flagDir%>/black.gif" style="height: 13px" onclick="setFlag(this.src, 'black.gif');">
            <img src="<%=flagDir%>/blackx.gif" style="height: 13px" onclick="setFlag(this.src, 'blackx.gif');">
            <img src="<%=flagDir%>/moveover.gif" style="height: 13px" onclick="setFlag(this.src, 'moveover.gif');">
            <img src="<%=flagDir%>/checkered.gif" style="height: 13px" onclick="setFlag(this.src, 'checkered.gif');">
        </div>
    </body>
</html>
