#!/usr/bin/env awk

    BEGIN { 
        RS="\0"; 
        ORS="\0"
        subscribe_str = ("SUBSCRIBE\ndestination:" queue "\nactivemq.prefetchSize:1\nack:client\n\n")

        #CONNECT and SUBSCRIBE to "queue"
        print "CONNECT\n\n"
        print subscribe_str
        fflush()
    }

    { 
        # ActiveMQ appear to use nul/lf as separator, so strip newline
        sub("^\n", "") 
        id = extract_msgid($0) 
        body = extract_body($0)

        if (id != "") {
            cmd = ( usercmd " >&2")
            print body | cmd;
            r = close(cmd);

            if (r == 0) {
                print "ACK\n" id "\n"
            } else {
                print ("UNSUBSCRIBE\ndestination:" queue "\n\n")
                system("sleep 1")
                print subscribe_str          
            }
            fflush()
        }
    }

    function extract_msgid(msg) {
        match(msg, "message-id:[[:graph:]]*\n", a)
        return a[0]
    }

    function extract_body(msg) {
        return substr( msg, match($0, "\n\n") + 2 )
    } 

