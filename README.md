# f1clamav-formula

Generic formula for installing ClamAV (clamav, clamav-update, clamd)  

## To-Do:  
  Current command that runs on VirusEvent triggering has the AWS region hard coded in  
  Finish templating .conf files to allow for more configuration options set in pillar data.  
    
    * LogFile location
    * LogFileMaxSize (May use M or m for megabytes)
    * LogTime (Log time with each message)
    * LogSyslog (Use system logger)
    * TCPSocket
    * TCPAddr
    * User (defaults to clamscan)
    * Cron schedule for freshclam
    
      

Pillar Definition:

```
clamav:
  paths:
    - /a/path/you/want/to/scan
    - /one/or/more
    - /omitting/this/will/make/onaccessscanner/not/do/anything
  sns_arn:
    - arn:of:sns:topic:for:notifications
  cron:
    dailyscan:
      cmd: "/bin/ls"
      user: "root"
      hour: "1"
      minute: "00"
      identifier: "clamcron"
```

