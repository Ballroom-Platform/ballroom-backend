import ballerina/jballerina.java;
import ballerina/jballerina.java.arrays as jarrays;

# Ballerina class mapping for the Java `java.io.InputStreamReader` class.
@java:Binding {'class: "java.io.InputStreamReader"}
public distinct class InputStreamReader {

    *java:JObject;
    *Reader;

    # The `handle` field that stores the reference to the `java.io.InputStreamReader` object.
    public handle jObj;

    # The init function of the Ballerina class mapping the `java.io.InputStreamReader` Java class.
    #
    # + obj - The `handle` value containing the Java reference of the object.
    public function init(handle obj) {
        self.jObj = obj;
    }

    # The function to retrieve the string representation of the Ballerina class mapping the `java.io.InputStreamReader` Java class.
    #
    # + return - The `string` form of the Java object instance.
    public function toString() returns string {
        return java:toString(self.jObj) ?: "null";
    }
    # The function that maps to the `close` method of `java.io.InputStreamReader`.
    #
    # + return - The `IOException` value returning from the Java mapping.
    public function close() returns IOException? {
        error|() externalObj = java_io_InputStreamReader_close(self.jObj);
        if (externalObj is error) {
            IOException e = error IOException(IOEXCEPTION, externalObj, message = externalObj.message());
            return e;
        }
    }

    # The function that maps to the `equals` method of `java.io.InputStreamReader`.
    #
    # + arg0 - The `Object` value required to map with the Java method parameter.
    # + return - The `boolean` value returning from the Java mapping.
    public function 'equals(Object arg0) returns boolean {
        return java_io_InputStreamReader_equals(self.jObj, arg0.jObj);
    }

    # The function that maps to the `getClass` method of `java.io.InputStreamReader`.
    #
    # + return - The `Class` value returning from the Java mapping.
    public function getClass() returns Class {
        handle externalObj = java_io_InputStreamReader_getClass(self.jObj);
        Class newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `getEncoding` method of `java.io.InputStreamReader`.
    #
    # + return - The `string` value returning from the Java mapping.
    public function getEncoding() returns string? {
        return java:toString(java_io_InputStreamReader_getEncoding(self.jObj));
    }

    # The function that maps to the `hashCode` method of `java.io.InputStreamReader`.
    #
    # + return - The `int` value returning from the Java mapping.
    public function hashCode() returns int {
        return java_io_InputStreamReader_hashCode(self.jObj);
    }

    # The function that maps to the `mark` method of `java.io.InputStreamReader`.
    #
    # + arg0 - The `int` value required to map with the Java method parameter.
    # + return - The `IOException` value returning from the Java mapping.
    public function mark(int arg0) returns IOException? {
        error|() externalObj = java_io_InputStreamReader_mark(self.jObj, arg0);
        if (externalObj is error) {
            IOException e = error IOException(IOEXCEPTION, externalObj, message = externalObj.message());
            return e;
        }
    }

    # The function that maps to the `markSupported` method of `java.io.InputStreamReader`.
    #
    # + return - The `boolean` value returning from the Java mapping.
    public function markSupported() returns boolean {
        return java_io_InputStreamReader_markSupported(self.jObj);
    }

    # The function that maps to the `notify` method of `java.io.InputStreamReader`.
    public function notify() {
        java_io_InputStreamReader_notify(self.jObj);
    }

    # The function that maps to the `notifyAll` method of `java.io.InputStreamReader`.
    public function notifyAll() {
        java_io_InputStreamReader_notifyAll(self.jObj);
    }

    # The function that maps to the `read` method of `java.io.InputStreamReader`.
    #
    # + return - The `int` or the `IOException` value returning from the Java mapping.
    public function read() returns int|IOException {
        int|error externalObj = java_io_InputStreamReader_read(self.jObj);
        if (externalObj is error) {
            IOException e = error IOException(IOEXCEPTION, externalObj, message = externalObj.message());
            return e;
        } else {
            return externalObj;
        }
    }

    # The function that maps to the `read` method of `java.io.InputStreamReader`.
    #
    # + arg0 - The `int[]` value required to map with the Java method parameter.
    # + return - The `int` or the `IOException` value returning from the Java mapping.
    public function read2(int[] arg0) returns int|IOException|error {
        int|error externalObj = java_io_InputStreamReader_read2(self.jObj, check jarrays:toHandle(arg0, "char"));
        if (externalObj is error) {
            IOException e = error IOException(IOEXCEPTION, externalObj, message = externalObj.message());
            return e;
        } else {
            return externalObj;
        }
    }

    # The function that maps to the `read` method of `java.io.InputStreamReader`.
    #
    # + arg0 - The `int[]` value required to map with the Java method parameter.
    # + arg1 - The `int` value required to map with the Java method parameter.
    # + arg2 - The `int` value required to map with the Java method parameter.
    # + return - The `int` or the `IOException` value returning from the Java mapping.
    public function read3(int[] arg0, int arg1, int arg2) returns int|IOException|error {
        int|error externalObj = java_io_InputStreamReader_read3(self.jObj, check jarrays:toHandle(arg0, "char"), arg1, arg2);
        if (externalObj is error) {
            IOException e = error IOException(IOEXCEPTION, externalObj, message = externalObj.message());
            return e;
        } else {
            return externalObj;
        }
    }

    # The function that maps to the `read` method of `java.io.InputStreamReader`.
    #
    # + arg0 - The `CharBuffer` value required to map with the Java method parameter.
    # + return - The `int` or the `IOException` value returning from the Java mapping.
    public function read4(CharBuffer arg0) returns int|IOException {
        int|error externalObj = java_io_InputStreamReader_read4(self.jObj, arg0.jObj);
        if (externalObj is error) {
            IOException e = error IOException(IOEXCEPTION, externalObj, message = externalObj.message());
            return e;
        } else {
            return externalObj;
        }
    }

    # The function that maps to the `ready` method of `java.io.InputStreamReader`.
    #
    # + return - The `boolean` or the `IOException` value returning from the Java mapping.
    public function ready() returns boolean|IOException {
        boolean|error externalObj = java_io_InputStreamReader_ready(self.jObj);
        if (externalObj is error) {
            IOException e = error IOException(IOEXCEPTION, externalObj, message = externalObj.message());
            return e;
        } else {
            return externalObj;
        }
    }

    # The function that maps to the `reset` method of `java.io.InputStreamReader`.
    #
    # + return - The `IOException` value returning from the Java mapping.
    public function reset() returns IOException? {
        error|() externalObj = java_io_InputStreamReader_reset(self.jObj);
        if (externalObj is error) {
            IOException e = error IOException(IOEXCEPTION, externalObj, message = externalObj.message());
            return e;
        }
    }

    # The function that maps to the `skip` method of `java.io.InputStreamReader`.
    #
    # + arg0 - The `int` value required to map with the Java method parameter.
    # + return - The `int` or the `IOException` value returning from the Java mapping.
    public function skip(int arg0) returns int|IOException {
        int|error externalObj = java_io_InputStreamReader_skip(self.jObj, arg0);
        if (externalObj is error) {
            IOException e = error IOException(IOEXCEPTION, externalObj, message = externalObj.message());
            return e;
        } else {
            return externalObj;
        }
    }

    # The function that maps to the `transferTo` method of `java.io.InputStreamReader`.
    #
    # + arg0 - The `Writer` value required to map with the Java method parameter.
    # + return - The `int` or the `IOException` value returning from the Java mapping.
    public function transferTo(Writer arg0) returns int|IOException {
        int|error externalObj = java_io_InputStreamReader_transferTo(self.jObj, arg0.jObj);
        if (externalObj is error) {
            IOException e = error IOException(IOEXCEPTION, externalObj, message = externalObj.message());
            return e;
        } else {
            return externalObj;
        }
    }

    # The function that maps to the `wait` method of `java.io.InputStreamReader`.
    #
    # + return - The `InterruptedException` value returning from the Java mapping.
    public function 'wait() returns InterruptedException? {
        error|() externalObj = java_io_InputStreamReader_wait(self.jObj);
        if (externalObj is error) {
            InterruptedException e = error InterruptedException(INTERRUPTEDEXCEPTION, externalObj, message = externalObj.message());
            return e;
        }
    }

    # The function that maps to the `wait` method of `java.io.InputStreamReader`.
    #
    # + arg0 - The `int` value required to map with the Java method parameter.
    # + return - The `InterruptedException` value returning from the Java mapping.
    public function wait2(int arg0) returns InterruptedException? {
        error|() externalObj = java_io_InputStreamReader_wait2(self.jObj, arg0);
        if (externalObj is error) {
            InterruptedException e = error InterruptedException(INTERRUPTEDEXCEPTION, externalObj, message = externalObj.message());
            return e;
        }
    }

    # The function that maps to the `wait` method of `java.io.InputStreamReader`.
    #
    # + arg0 - The `int` value required to map with the Java method parameter.
    # + arg1 - The `int` value required to map with the Java method parameter.
    # + return - The `InterruptedException` value returning from the Java mapping.
    public function wait3(int arg0, int arg1) returns InterruptedException? {
        error|() externalObj = java_io_InputStreamReader_wait3(self.jObj, arg0, arg1);
        if (externalObj is error) {
            InterruptedException e = error InterruptedException(INTERRUPTEDEXCEPTION, externalObj, message = externalObj.message());
            return e;
        }
    }

}

# The constructor function to generate an object of `java.io.InputStreamReader`.
#
# + arg0 - The `InputStream` value required to map with the Java constructor parameter.
# + return - The new `InputStreamReader` class generated.
public function newInputStreamReader1(InputStream arg0) returns InputStreamReader {
    handle externalObj = java_io_InputStreamReader_newInputStreamReader1(arg0.jObj);
    InputStreamReader newObj = new (externalObj);
    return newObj;
}

# The constructor function to generate an object of `java.io.InputStreamReader`.
#
# + arg0 - The `InputStream` value required to map with the Java constructor parameter.
# + arg1 - The `Charset` value required to map with the Java constructor parameter.
# + return - The new `InputStreamReader` class generated.
public function newInputStreamReader2(InputStream arg0, Charset arg1) returns InputStreamReader {
    handle externalObj = java_io_InputStreamReader_newInputStreamReader2(arg0.jObj, arg1.jObj);
    InputStreamReader newObj = new (externalObj);
    return newObj;
}

# The constructor function to generate an object of `java.io.InputStreamReader`.
#
# + arg0 - The `InputStream` value required to map with the Java constructor parameter.
# + arg1 - The `CharsetDecoder` value required to map with the Java constructor parameter.
# + return - The new `InputStreamReader` class generated.
public function newInputStreamReader3(InputStream arg0, CharsetDecoder arg1) returns InputStreamReader {
    handle externalObj = java_io_InputStreamReader_newInputStreamReader3(arg0.jObj, arg1.jObj);
    InputStreamReader newObj = new (externalObj);
    return newObj;
}

# The constructor function to generate an object of `java.io.InputStreamReader`.
#
# + arg0 - The `InputStream` value required to map with the Java constructor parameter.
# + arg1 - The `string` value required to map with the Java constructor parameter.
# + return - The new `InputStreamReader` class or `UnsupportedEncodingException` error generated.
public function newInputStreamReader4(InputStream arg0, string arg1) returns InputStreamReader|UnsupportedEncodingException {
    handle|error externalObj = java_io_InputStreamReader_newInputStreamReader4(arg0.jObj, java:fromString(arg1));
    if (externalObj is error) {
        UnsupportedEncodingException e = error UnsupportedEncodingException(UNSUPPORTEDENCODINGEXCEPTION, externalObj, message = externalObj.message());
        return e;
    } else {
        InputStreamReader newObj = new (externalObj);
        return newObj;
    }
}

# The function that maps to the `nullReader` method of `java.io.InputStreamReader`.
#
# + return - The `Reader` value returning from the Java mapping.
public function InputStreamReader_nullReader() returns Reader {
    handle externalObj = java_io_InputStreamReader_nullReader();
    Reader newObj = new (externalObj);
    return newObj;
}

function java_io_InputStreamReader_close(handle receiver) returns error? = @java:Method {
    name: "close",
    'class: "java.io.InputStreamReader",
    paramTypes: []
} external;

function java_io_InputStreamReader_equals(handle receiver, handle arg0) returns boolean = @java:Method {
    name: "equals",
    'class: "java.io.InputStreamReader",
    paramTypes: ["java.lang.Object"]
} external;

function java_io_InputStreamReader_getClass(handle receiver) returns handle = @java:Method {
    name: "getClass",
    'class: "java.io.InputStreamReader",
    paramTypes: []
} external;

function java_io_InputStreamReader_getEncoding(handle receiver) returns handle = @java:Method {
    name: "getEncoding",
    'class: "java.io.InputStreamReader",
    paramTypes: []
} external;

function java_io_InputStreamReader_hashCode(handle receiver) returns int = @java:Method {
    name: "hashCode",
    'class: "java.io.InputStreamReader",
    paramTypes: []
} external;

function java_io_InputStreamReader_mark(handle receiver, int arg0) returns error? = @java:Method {
    name: "mark",
    'class: "java.io.InputStreamReader",
    paramTypes: ["int"]
} external;

function java_io_InputStreamReader_markSupported(handle receiver) returns boolean = @java:Method {
    name: "markSupported",
    'class: "java.io.InputStreamReader",
    paramTypes: []
} external;

function java_io_InputStreamReader_notify(handle receiver) = @java:Method {
    name: "notify",
    'class: "java.io.InputStreamReader",
    paramTypes: []
} external;

function java_io_InputStreamReader_notifyAll(handle receiver) = @java:Method {
    name: "notifyAll",
    'class: "java.io.InputStreamReader",
    paramTypes: []
} external;

function java_io_InputStreamReader_nullReader() returns handle = @java:Method {
    name: "nullReader",
    'class: "java.io.InputStreamReader",
    paramTypes: []
} external;

function java_io_InputStreamReader_read(handle receiver) returns int|error = @java:Method {
    name: "read",
    'class: "java.io.InputStreamReader",
    paramTypes: []
} external;

function java_io_InputStreamReader_read2(handle receiver, handle arg0) returns int|error = @java:Method {
    name: "read",
    'class: "java.io.InputStreamReader",
    paramTypes: ["[C"]
} external;

function java_io_InputStreamReader_read3(handle receiver, handle arg0, int arg1, int arg2) returns int|error = @java:Method {
    name: "read",
    'class: "java.io.InputStreamReader",
    paramTypes: ["[C", "int", "int"]
} external;

function java_io_InputStreamReader_read4(handle receiver, handle arg0) returns int|error = @java:Method {
    name: "read",
    'class: "java.io.InputStreamReader",
    paramTypes: ["java.nio.CharBuffer"]
} external;

function java_io_InputStreamReader_ready(handle receiver) returns boolean|error = @java:Method {
    name: "ready",
    'class: "java.io.InputStreamReader",
    paramTypes: []
} external;

function java_io_InputStreamReader_reset(handle receiver) returns error? = @java:Method {
    name: "reset",
    'class: "java.io.InputStreamReader",
    paramTypes: []
} external;

function java_io_InputStreamReader_skip(handle receiver, int arg0) returns int|error = @java:Method {
    name: "skip",
    'class: "java.io.InputStreamReader",
    paramTypes: ["long"]
} external;

function java_io_InputStreamReader_transferTo(handle receiver, handle arg0) returns int|error = @java:Method {
    name: "transferTo",
    'class: "java.io.InputStreamReader",
    paramTypes: ["java.io.Writer"]
} external;

function java_io_InputStreamReader_wait(handle receiver) returns error? = @java:Method {
    name: "wait",
    'class: "java.io.InputStreamReader",
    paramTypes: []
} external;

function java_io_InputStreamReader_wait2(handle receiver, int arg0) returns error? = @java:Method {
    name: "wait",
    'class: "java.io.InputStreamReader",
    paramTypes: ["long"]
} external;

function java_io_InputStreamReader_wait3(handle receiver, int arg0, int arg1) returns error? = @java:Method {
    name: "wait",
    'class: "java.io.InputStreamReader",
    paramTypes: ["long", "int"]
} external;

function java_io_InputStreamReader_newInputStreamReader1(handle arg0) returns handle = @java:Constructor {
    'class: "java.io.InputStreamReader",
    paramTypes: ["java.io.InputStream"]
} external;

function java_io_InputStreamReader_newInputStreamReader2(handle arg0, handle arg1) returns handle = @java:Constructor {
    'class: "java.io.InputStreamReader",
    paramTypes: ["java.io.InputStream", "java.nio.charset.Charset"]
} external;

function java_io_InputStreamReader_newInputStreamReader3(handle arg0, handle arg1) returns handle = @java:Constructor {
    'class: "java.io.InputStreamReader",
    paramTypes: ["java.io.InputStream", "java.nio.charset.CharsetDecoder"]
} external;

function java_io_InputStreamReader_newInputStreamReader4(handle arg0, handle arg1) returns handle|error = @java:Constructor {
    'class: "java.io.InputStreamReader",
    paramTypes: ["java.io.InputStream", "java.lang.String"]
} external;

