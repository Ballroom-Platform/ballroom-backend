import ballerina/jballerina.java;
import ballerina/jballerina.java.arrays as jarrays;

# Ballerina class mapping for the Java `java.io.Reader` class.
@java:Binding {'class: "java.io.Reader"}
public distinct class Reader {

    *java:JObject;
    *Object;

    # The `handle` field that stores the reference to the `java.io.Reader` object.
    public handle jObj;

    # The init function of the Ballerina class mapping the `java.io.Reader` Java class.
    #
    # + obj - The `handle` value containing the Java reference of the object.
    public function init(handle obj) {
        self.jObj = obj;
    }

    # The function to retrieve the string representation of the Ballerina class mapping the `java.io.Reader` Java class.
    #
    # + return - The `string` form of the Java object instance.
    public function toString() returns string {
        return java:toString(self.jObj) ?: "null";
    }
    # The function that maps to the `close` method of `java.io.Reader`.
    #
    # + return - The `IOException` value returning from the Java mapping.
    public function close() returns IOException? {
        error|() externalObj = java_io_Reader_close(self.jObj);
        if (externalObj is error) {
            IOException e = error IOException(IOEXCEPTION, externalObj, message = externalObj.message());
            return e;
        }
    }

    # The function that maps to the `equals` method of `java.io.Reader`.
    #
    # + arg0 - The `Object` value required to map with the Java method parameter.
    # + return - The `boolean` value returning from the Java mapping.
    public function 'equals(Object arg0) returns boolean {
        return java_io_Reader_equals(self.jObj, arg0.jObj);
    }

    # The function that maps to the `getClass` method of `java.io.Reader`.
    #
    # + return - The `Class` value returning from the Java mapping.
    public function getClass() returns Class {
        handle externalObj = java_io_Reader_getClass(self.jObj);
        Class newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `hashCode` method of `java.io.Reader`.
    #
    # + return - The `int` value returning from the Java mapping.
    public function hashCode() returns int {
        return java_io_Reader_hashCode(self.jObj);
    }

    # The function that maps to the `mark` method of `java.io.Reader`.
    #
    # + arg0 - The `int` value required to map with the Java method parameter.
    # + return - The `IOException` value returning from the Java mapping.
    public function mark(int arg0) returns IOException? {
        error|() externalObj = java_io_Reader_mark(self.jObj, arg0);
        if (externalObj is error) {
            IOException e = error IOException(IOEXCEPTION, externalObj, message = externalObj.message());
            return e;
        }
    }

    # The function that maps to the `markSupported` method of `java.io.Reader`.
    #
    # + return - The `boolean` value returning from the Java mapping.
    public function markSupported() returns boolean {
        return java_io_Reader_markSupported(self.jObj);
    }

    # The function that maps to the `notify` method of `java.io.Reader`.
    public function notify() {
        java_io_Reader_notify(self.jObj);
    }

    # The function that maps to the `notifyAll` method of `java.io.Reader`.
    public function notifyAll() {
        java_io_Reader_notifyAll(self.jObj);
    }

    # The function that maps to the `read` method of `java.io.Reader`.
    #
    # + return - The `int` or the `IOException` value returning from the Java mapping.
    public function read() returns int|IOException {
        int|error externalObj = java_io_Reader_read(self.jObj);
        if (externalObj is error) {
            IOException e = error IOException(IOEXCEPTION, externalObj, message = externalObj.message());
            return e;
        } else {
            return externalObj;
        }
    }

    # The function that maps to the `read` method of `java.io.Reader`.
    #
    # + arg0 - The `int[]` value required to map with the Java method parameter.
    # + return - The `int` or the `IOException` value returning from the Java mapping.
    public function read2(int[] arg0) returns int|IOException|error {
        int|error externalObj = java_io_Reader_read2(self.jObj, check jarrays:toHandle(arg0, "char"));
        if (externalObj is error) {
            IOException e = error IOException(IOEXCEPTION, externalObj, message = externalObj.message());
            return e;
        } else {
            return externalObj;
        }
    }

    # The function that maps to the `read` method of `java.io.Reader`.
    #
    # + arg0 - The `int[]` value required to map with the Java method parameter.
    # + arg1 - The `int` value required to map with the Java method parameter.
    # + arg2 - The `int` value required to map with the Java method parameter.
    # + return - The `int` or the `IOException` value returning from the Java mapping.
    public function read3(int[] arg0, int arg1, int arg2) returns int|IOException|error {
        int|error externalObj = java_io_Reader_read3(self.jObj, check jarrays:toHandle(arg0, "char"), arg1, arg2);
        if (externalObj is error) {
            IOException e = error IOException(IOEXCEPTION, externalObj, message = externalObj.message());
            return e;
        } else {
            return externalObj;
        }
    }

    # The function that maps to the `read` method of `java.io.Reader`.
    #
    # + arg0 - The `CharBuffer` value required to map with the Java method parameter.
    # + return - The `int` or the `IOException` value returning from the Java mapping.
    public function read4(CharBuffer arg0) returns int|IOException {
        int|error externalObj = java_io_Reader_read4(self.jObj, arg0.jObj);
        if (externalObj is error) {
            IOException e = error IOException(IOEXCEPTION, externalObj, message = externalObj.message());
            return e;
        } else {
            return externalObj;
        }
    }

    # The function that maps to the `ready` method of `java.io.Reader`.
    #
    # + return - The `boolean` or the `IOException` value returning from the Java mapping.
    public function ready() returns boolean|IOException {
        boolean|error externalObj = java_io_Reader_ready(self.jObj);
        if (externalObj is error) {
            IOException e = error IOException(IOEXCEPTION, externalObj, message = externalObj.message());
            return e;
        } else {
            return externalObj;
        }
    }

    # The function that maps to the `reset` method of `java.io.Reader`.
    #
    # + return - The `IOException` value returning from the Java mapping.
    public function reset() returns IOException? {
        error|() externalObj = java_io_Reader_reset(self.jObj);
        if (externalObj is error) {
            IOException e = error IOException(IOEXCEPTION, externalObj, message = externalObj.message());
            return e;
        }
    }

    # The function that maps to the `skip` method of `java.io.Reader`.
    #
    # + arg0 - The `int` value required to map with the Java method parameter.
    # + return - The `int` or the `IOException` value returning from the Java mapping.
    public function skip(int arg0) returns int|IOException {
        int|error externalObj = java_io_Reader_skip(self.jObj, arg0);
        if (externalObj is error) {
            IOException e = error IOException(IOEXCEPTION, externalObj, message = externalObj.message());
            return e;
        } else {
            return externalObj;
        }
    }

    # The function that maps to the `transferTo` method of `java.io.Reader`.
    #
    # + arg0 - The `Writer` value required to map with the Java method parameter.
    # + return - The `int` or the `IOException` value returning from the Java mapping.
    public function transferTo(Writer arg0) returns int|IOException {
        int|error externalObj = java_io_Reader_transferTo(self.jObj, arg0.jObj);
        if (externalObj is error) {
            IOException e = error IOException(IOEXCEPTION, externalObj, message = externalObj.message());
            return e;
        } else {
            return externalObj;
        }
    }

    # The function that maps to the `wait` method of `java.io.Reader`.
    #
    # + return - The `InterruptedException` value returning from the Java mapping.
    public function 'wait() returns InterruptedException? {
        error|() externalObj = java_io_Reader_wait(self.jObj);
        if (externalObj is error) {
            InterruptedException e = error InterruptedException(INTERRUPTEDEXCEPTION, externalObj, message = externalObj.message());
            return e;
        }
    }

    # The function that maps to the `wait` method of `java.io.Reader`.
    #
    # + arg0 - The `int` value required to map with the Java method parameter.
    # + return - The `InterruptedException` value returning from the Java mapping.
    public function wait2(int arg0) returns InterruptedException? {
        error|() externalObj = java_io_Reader_wait2(self.jObj, arg0);
        if (externalObj is error) {
            InterruptedException e = error InterruptedException(INTERRUPTEDEXCEPTION, externalObj, message = externalObj.message());
            return e;
        }
    }

    # The function that maps to the `wait` method of `java.io.Reader`.
    #
    # + arg0 - The `int` value required to map with the Java method parameter.
    # + arg1 - The `int` value required to map with the Java method parameter.
    # + return - The `InterruptedException` value returning from the Java mapping.
    public function wait3(int arg0, int arg1) returns InterruptedException? {
        error|() externalObj = java_io_Reader_wait3(self.jObj, arg0, arg1);
        if (externalObj is error) {
            InterruptedException e = error InterruptedException(INTERRUPTEDEXCEPTION, externalObj, message = externalObj.message());
            return e;
        }
    }

}

# The function that maps to the `nullReader` method of `java.io.Reader`.
#
# + return - The `Reader` value returning from the Java mapping.
public function Reader_nullReader() returns Reader {
    handle externalObj = java_io_Reader_nullReader();
    Reader newObj = new (externalObj);
    return newObj;
}

function java_io_Reader_close(handle receiver) returns error? = @java:Method {
    name: "close",
    'class: "java.io.Reader",
    paramTypes: []
} external;

function java_io_Reader_equals(handle receiver, handle arg0) returns boolean = @java:Method {
    name: "equals",
    'class: "java.io.Reader",
    paramTypes: ["java.lang.Object"]
} external;

function java_io_Reader_getClass(handle receiver) returns handle = @java:Method {
    name: "getClass",
    'class: "java.io.Reader",
    paramTypes: []
} external;

function java_io_Reader_hashCode(handle receiver) returns int = @java:Method {
    name: "hashCode",
    'class: "java.io.Reader",
    paramTypes: []
} external;

function java_io_Reader_mark(handle receiver, int arg0) returns error? = @java:Method {
    name: "mark",
    'class: "java.io.Reader",
    paramTypes: ["int"]
} external;

function java_io_Reader_markSupported(handle receiver) returns boolean = @java:Method {
    name: "markSupported",
    'class: "java.io.Reader",
    paramTypes: []
} external;

function java_io_Reader_notify(handle receiver) = @java:Method {
    name: "notify",
    'class: "java.io.Reader",
    paramTypes: []
} external;

function java_io_Reader_notifyAll(handle receiver) = @java:Method {
    name: "notifyAll",
    'class: "java.io.Reader",
    paramTypes: []
} external;

function java_io_Reader_nullReader() returns handle = @java:Method {
    name: "nullReader",
    'class: "java.io.Reader",
    paramTypes: []
} external;

function java_io_Reader_read(handle receiver) returns int|error = @java:Method {
    name: "read",
    'class: "java.io.Reader",
    paramTypes: []
} external;

function java_io_Reader_read2(handle receiver, handle arg0) returns int|error = @java:Method {
    name: "read",
    'class: "java.io.Reader",
    paramTypes: ["[C"]
} external;

function java_io_Reader_read3(handle receiver, handle arg0, int arg1, int arg2) returns int|error = @java:Method {
    name: "read",
    'class: "java.io.Reader",
    paramTypes: ["[C", "int", "int"]
} external;

function java_io_Reader_read4(handle receiver, handle arg0) returns int|error = @java:Method {
    name: "read",
    'class: "java.io.Reader",
    paramTypes: ["java.nio.CharBuffer"]
} external;

function java_io_Reader_ready(handle receiver) returns boolean|error = @java:Method {
    name: "ready",
    'class: "java.io.Reader",
    paramTypes: []
} external;

function java_io_Reader_reset(handle receiver) returns error? = @java:Method {
    name: "reset",
    'class: "java.io.Reader",
    paramTypes: []
} external;

function java_io_Reader_skip(handle receiver, int arg0) returns int|error = @java:Method {
    name: "skip",
    'class: "java.io.Reader",
    paramTypes: ["long"]
} external;

function java_io_Reader_transferTo(handle receiver, handle arg0) returns int|error = @java:Method {
    name: "transferTo",
    'class: "java.io.Reader",
    paramTypes: ["java.io.Writer"]
} external;

function java_io_Reader_wait(handle receiver) returns error? = @java:Method {
    name: "wait",
    'class: "java.io.Reader",
    paramTypes: []
} external;

function java_io_Reader_wait2(handle receiver, int arg0) returns error? = @java:Method {
    name: "wait",
    'class: "java.io.Reader",
    paramTypes: ["long"]
} external;

function java_io_Reader_wait3(handle receiver, int arg0, int arg1) returns error? = @java:Method {
    name: "wait",
    'class: "java.io.Reader",
    paramTypes: ["long", "int"]
} external;

