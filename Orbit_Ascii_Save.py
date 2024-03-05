#Author: Samuel Carter, University of Northumbria
#Date:29/01/2024
#Description:
#This code is for use alongside Dr Lynn B Wilson's IDL code for Wind 3DP
#This code obtains the orbit ascii files required for that code 
#It fills out the form for the required data, and saves to a user defined directory in the correct format
#
#
#
#
#
#
#requires google chrome
#required packages: selenium, tkinter, datetime, os
#
import tkinter as tk
from tkinter import simpledialog
import datetime as dt
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.select import Select
import os

##############################################



##############################################
#take user date inputs

ROOT = tk.Tk()
ROOT.withdraw()
# the input dialog
StartDate = simpledialog.askstring(title="Start Date",
                                  prompt="Enter desired start date (dd/mm/YYYY):")

EndDate = simpledialog.askstring(title="End Date",
                                  prompt="Enter desired end date (inclusive, dd/mm/YYYY):")

SaveDir = simpledialog.askstring(title="Save Directory",
                                  prompt="Enter desired directory to store data")

SaveDir=os.path.join(SaveDir)

##############################################
#format user date range into list of dates and times between

stringstart=StartDate+" 00:00:00.000"

StartDateTime = dt.datetime.strptime(stringstart,"%d/%m/%Y %H:%M:%S.%f")

stringend=EndDate+" 00:00:00.000"

EndDateTime = dt.datetime.strptime(stringend,"%d/%m/%Y %H:%M:%S.%f")



###########################################
#loop through days and generate files from website

CurrentDay=StartDateTime

while CurrentDay <=EndDateTime:
    
    #define start and end times for form
    FormStart=CurrentDay
    FormEnd=CurrentDay+dt.timedelta(days=1)#for the exactly 24 hours of data
    
    #selenium setup, with chrome opening headless to allow background running
    options = webdriver.ChromeOptions()
    options.add_argument("--headless")    
    driver = webdriver.Chrome(options=options)
    #open the webpage
    driver.get("https://sscweb.gsfc.nasa.gov/cgi-bin/Locator.cgi")
    
    #select wind
    spacecraft = Select(driver.find_element(By.ID, "scvalues"))
    spacecraft.deselect_by_value('ace')#ace starts selected, but we don't want it
    spacecraft.select_by_value('wind')#select wind
    #start input
    start = driver.find_element(By.ID, "starttime")
    start.clear()#clear text from input box
    start.send_keys(str(FormStart))#enter the start date
        
    #end input
    end = driver.find_element(By.ID, "stoptime")
    end.clear()#clear text from input box
    end.send_keys(str(FormEnd))#enter the start date
    
    #select output options
    outputsOptions=driver.find_element(By.XPATH, "//input[@name='GO_TO'][@type='submit'][@value='Output Options']")
    outputsOptions.click()
    
    #select GSE xyz
    GSExyz=driver.find_element(By.ID, "GSE7")
    GSExyz.click()
    #select GSM xyz
    GSMxyz=driver.find_element(By.ID, "GSM7")
    GSMxyz.click()
    #select GSE lat/long
    GSElatlong=driver.find_element(By.ID, "GSE8")
    GSElatlong.click()
    #select GSE lat/long
    GSMlatlong=driver.find_element(By.ID, "GSM8")
    GSMlatlong.click()
    #select dipole l value
    DipL=driver.find_element(By.ID, "Dipole_L_Value")
    DipL.click()
    #select dipole inv lat
    DipInvLat=driver.find_element(By.ID, "Dipole_Inv_Lat")
    DipInvLat.click()
    
    
    #select output units formatting
    outputsOptionsForm=driver.find_element(By.XPATH, "//input[@name='GO_TO'][@type='submit'][@value='Output Units/Formatting']")
    outputsOptionsForm.click()
    
    
    #select yy/mm/dd
    yymmdd=driver.find_element(By.ID, "yy/mm/dd")
    yymmdd.click()
    
    #select hh:mm:ss
    hhmmss=driver.find_element(By.ID, "hh:mm:ss")
    hhmmss.click()
    
    #select km-Kilometers
    kms=driver.find_element(By.ID, "km_-_Kilometers")
    kms.click()
    
    #distance to 3 d.p
    decplace=driver.find_element(By.ID, "distdec")
    decplace.clear()#clear text from input box
    decplace.send_keys("3")
    
    #submit querry and generate data page
    submit=driver.find_element(By.ID, "sbplot")
    submit.click()
    
    #pull the data    
    data=driver.find_element(By.XPATH, "/html/body/div/form/pre/pre").text
    
    #form the save file from the data
    lines=data.split('\n')#split into lines
    LinesToSave=list()
    LinesToSave.append(lines[8])
    LinesToSave.append(lines[9])
    LinesToSave.extend(lines[34:40])
    LinesToSave.append("FORMAT='(a17,3f16.3,2f7.2,3f16.3,2f7.2,2f7.1)'")
    LinesToSave.extend(lines[39:])
    
    #form filename
    filename=f"wind_{CurrentDay.strftime('%m-%d-%Y')}_XYZ-GSE-GSM_Lat-Long-GSE_L-Value_Invar-Lat.txt"
    
    #join the filename to the data directory
    path=os.path.join(SaveDir,filename)
    
    #write the file
    file=open(path, 'w')
    file.writelines(line + '\n' for line in LinesToSave)
    file.close()
    
    #wait=input('Press Enter to continue.')
    print(CurrentDay)
    #close webpage
    driver.close()
    #puts end of day as start of next
    CurrentDay=FormEnd
    