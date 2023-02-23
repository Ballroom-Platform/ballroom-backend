import ballerina/jballerina.java;
import ballerina/jballerina.java.arrays as jarrays;

# Ballerina class mapping for the Java `java.lang.ProcessBuilder` class.
@java:Binding {'class: "java.lang.ProcessBuilder"}
public distinct class ProcessBuilder {

    *java:JObject;
    *Object;

    # The `handle` field that stores the reference to the `java.lang.ProcessBuilder` object.
    public handle jObj;

    # The init function of the Ballerina class mapping the `java.lang.ProcessBuilder` Java class.
    #
    # + obj - The `handle` value containing the Java reference of the object.
    public function init(handle obj) {
        self.jObj = obj;
    }

    # The function to retrieve the string representation of the Ballerina class mapping the `java.lang.ProcessBuilder` Java class.
    #
    # + return - The `string` form of the Java object instance.
    public function toString() returns string {
        return java:toString(self.jObj) ?: "null";
    }
    # The function that maps to the `command` method of `java.lang.ProcessBuilder`.
    #
    # + return - The `List` value returning from the Java mapping.
    public function command() returns List {
        handle externalObj = java_lang_ProcessBuilder_command(self.jObj);
        List newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `command` method of `java.lang.ProcessBuilder`.
    #
    # + arg0 - The `List` value required to map with the Java method parameter.
    # + return - The `ProcessBuilder` value returning from the Java mapping.
    public function command2(List arg0) returns ProcessBuilder {
        handle externalObj = java_lang_ProcessBuilder_command2(self.jObj, arg0.jObj);
        ProcessBuilder newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `command` method of `java.lang.ProcessBuilder`.
    #
    # + arg0 - The `string[]` value required to map with the Java method parameter.
    # + return - The `ProcessBuilder` value returning from the Java mapping.
    public function command3(string[] arg0) returns ProcessBuilder|error {
        handle externalObj = java_lang_ProcessBuilder_command3(self.jObj, check jarrays:toHandle(arg0, "java.lang.String"));
        ProcessBuilder newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `directory` method of `java.lang.ProcessBuilder`.
    #
    # + return - The `File` value returning from the Java mapping.
    public function directory() returns File {
        handle externalObj = java_lang_ProcessBuilder_directory(self.jObj);
        File newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `directory` method of `java.lang.ProcessBuilder`.
    #
    # + arg0 - The `File` value required to map with the Java method parameter.
    # + return - The `ProcessBuilder` value returning from the Java mapping.
    public function directory2(File arg0) returns ProcessBuilder {
        handle externalObj = java_lang_ProcessBuilder_directory2(self.jObj, arg0.jObj);
        ProcessBuilder newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `environment` method of `java.lang.ProcessBuilder`.
    #
    # + return - The `Map` value returning from the Java mapping.
    public function environment() returns Map {
        handle externalObj = java_lang_ProcessBuilder_environment(self.jObj);
        Map newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `equals` method of `java.lang.ProcessBuilder`.
    #
    # + arg0 - The `Object` value required to map with the Java method parameter.
    # + return - The `boolean` value returning from the Java mapping.
    public function 'equals(Object arg0) returns boolean {
        return java_lang_ProcessBuilder_equals(self.jObj, arg0.jObj);
    }

    # The function that maps to the `getClass` method of `java.lang.ProcessBuilder`.
    #
    # + return - The `Class` value returning from the Java mapping.
    public function getClass() returns Class {
        handle externalObj = java_lang_ProcessBuilder_getClass(self.jObj);
        Class newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `hashCode` method of `java.lang.ProcessBuilder`.
    #
    # + return - The `int` value returning from the Java mapping.
    public function hashCode() returns int {
        return java_lang_ProcessBuilder_hashCode(self.jObj);
    }

    # The function that maps to the `inheritIO` method of `java.lang.ProcessBuilder`.
    #
    # + return - The `ProcessBuilder` value returning from the Java mapping.
    public function inheritIO() returns ProcessBuilder {
        handle externalObj = java_lang_ProcessBuilder_inheritIO(self.jObj);
        ProcessBuilder newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `notify` method of `java.lang.ProcessBuilder`.
    public function notify() {
        java_lang_ProcessBuilder_notify(self.jObj);
    }

    # The function that maps to the `notifyAll` method of `java.lang.ProcessBuilder`.
    public function notifyAll() {
        java_lang_ProcessBuilder_notifyAll(self.jObj);
    }

    # The function that maps to the `redirectError` method of `java.lang.ProcessBuilder`.
    #
    # + return - The `Redirect` value returning from the Java mapping.
    public function redirectError() returns Redirect {
        handle externalObj = java_lang_ProcessBuilder_redirectError(self.jObj);
        Redirect newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `redirectError` method of `java.lang.ProcessBuilder`.
    #
    # + arg0 - The `File` value required to map with the Java method parameter.
    # + return - The `ProcessBuilder` value returning from the Java mapping.
    public function redirectError2(File arg0) returns ProcessBuilder {
        handle externalObj = java_lang_ProcessBuilder_redirectError2(self.jObj, arg0.jObj);
        ProcessBuilder newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `redirectError` method of `java.lang.ProcessBuilder`.
    #
    # + arg0 - The `Redirect` value required to map with the Java method parameter.
    # + return - The `ProcessBuilder` value returning from the Java mapping.
    public function redirectError3(Redirect arg0) returns ProcessBuilder {
        handle externalObj = java_lang_ProcessBuilder_redirectError3(self.jObj, arg0.jObj);
        ProcessBuilder newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `redirectErrorStream` method of `java.lang.ProcessBuilder`.
    #
    # + return - The `boolean` value returning from the Java mapping.
    public function redirectErrorStream() returns boolean {
        return java_lang_ProcessBuilder_redirectErrorStream(self.jObj);
    }

    # The function that maps to the `redirectErrorStream` method of `java.lang.ProcessBuilder`.
    #
    # + arg0 - The `boolean` value required to map with the Java method parameter.
    # + return - The `ProcessBuilder` value returning from the Java mapping.
    public function redirectErrorStream2(boolean arg0) returns ProcessBuilder {
        handle externalObj = java_lang_ProcessBuilder_redirectErrorStream2(self.jObj, arg0);
        ProcessBuilder newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `redirectInput` method of `java.lang.ProcessBuilder`.
    #
    # + return - The `Redirect` value returning from the Java mapping.
    public function redirectInput() returns Redirect {
        handle externalObj = java_lang_ProcessBuilder_redirectInput(self.jObj);
        Redirect newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `redirectInput` method of `java.lang.ProcessBuilder`.
    #
    # + arg0 - The `File` value required to map with the Java method parameter.
    # + return - The `ProcessBuilder` value returning from the Java mapping.
    public function redirectInput2(File arg0) returns ProcessBuilder {
        handle externalObj = java_lang_ProcessBuilder_redirectInput2(self.jObj, arg0.jObj);
        ProcessBuilder newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `redirectInput` method of `java.lang.ProcessBuilder`.
    #
    # + arg0 - The `Redirect` value required to map with the Java method parameter.
    # + return - The `ProcessBuilder` value returning from the Java mapping.
    public function redirectInput3(Redirect arg0) returns ProcessBuilder {
        handle externalObj = java_lang_ProcessBuilder_redirectInput3(self.jObj, arg0.jObj);
        ProcessBuilder newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `redirectOutput` method of `java.lang.ProcessBuilder`.
    #
    # + return - The `Redirect` value returning from the Java mapping.
    public function redirectOutput() returns Redirect {
        handle externalObj = java_lang_ProcessBuilder_redirectOutput(self.jObj);
        Redirect newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `redirectOutput` method of `java.lang.ProcessBuilder`.
    #
    # + arg0 - The `File` value required to map with the Java method parameter.
    # + return - The `ProcessBuilder` value returning from the Java mapping.
    public function redirectOutput2(File arg0) returns ProcessBuilder {
        handle externalObj = java_lang_ProcessBuilder_redirectOutput2(self.jObj, arg0.jObj);
        ProcessBuilder newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `redirectOutput` method of `java.lang.ProcessBuilder`.
    #
    # + arg0 - The `Redirect` value required to map with the Java method parameter.
    # + return - The `ProcessBuilder` value returning from the Java mapping.
    public function redirectOutput3(Redirect arg0) returns ProcessBuilder {
        handle externalObj = java_lang_ProcessBuilder_redirectOutput3(self.jObj, arg0.jObj);
        ProcessBuilder newObj = new (externalObj);
        return newObj;
    }

    # The function that maps to the `start` method of `java.lang.ProcessBuilder`.
    #
    # + return - The `Process` or the `IOException` value returning from the Java mapping.
    public function 'start() returns Process|IOException {
        handle|error externalObj = java_lang_ProcessBuilder_start(self.jObj);
        if (externalObj is error) {
            IOException e = error IOException(IOEXCEPTION, externalObj, message = externalObj.message());
            return e;
        } else {
            Process newObj = new (externalObj);
            return newObj;
        }
    }

    # The function that maps to the `wait` method of `java.lang.ProcessBuilder`.
    #
    # + return - The `InterruptedException` value returning from the Java mapping.
    public function 'wait() returns InterruptedException? {
        error|() externalObj = java_lang_ProcessBuilder_wait(self.jObj);
        if (externalObj is error) {
            InterruptedException e = error InterruptedException(INTERRUPTEDEXCEPTION, externalObj, message = externalObj.message());
            return e;
        }
    }

    # The function that maps to the `wait` method of `java.lang.ProcessBuilder`.
    #
    # + arg0 - The `int` value required to map with the Java method parameter.
    # + return - The `InterruptedException` value returning from the Java mapping.
    public function wait2(int arg0) returns InterruptedException? {
        error|() externalObj = java_lang_ProcessBuilder_wait2(self.jObj, arg0);
        if (externalObj is error) {
            InterruptedException e = error InterruptedException(INTERRUPTEDEXCEPTION, externalObj, message = externalObj.message());
            return e;
        }
    }

    # The function that maps to the `wait` method of `java.lang.ProcessBuilder`.
    #
    # + arg0 - The `int` value required to map with the Java method parameter.
    # + arg1 - The `int` value required to map with the Java method parameter.
    # + return - The `InterruptedException` value returning from the Java mapping.
    public function wait3(int arg0, int arg1) returns InterruptedException? {
        error|() externalObj = java_lang_ProcessBuilder_wait3(self.jObj, arg0, arg1);
        if (externalObj is error) {
            InterruptedException e = error InterruptedException(INTERRUPTEDEXCEPTION, externalObj, message = externalObj.message());
            return e;
        }
    }

}

# The constructor function to generate an object of `java.lang.ProcessBuilder`.
#
# + arg0 - The `List` value required to map with the Java constructor parameter.
# + return - The new `ProcessBuilder` class generated.
public function newProcessBuilder1(List arg0) returns ProcessBuilder {
    handle externalObj = java_lang_ProcessBuilder_newProcessBuilder1(arg0.jObj);
    ProcessBuilder newObj = new (externalObj);
    return newObj;
}

# The constructor function to generate an object of `java.lang.ProcessBuilder`.
#
# + arg0 - The `string[]` value required to map with the Java constructor parameter.
# + return - The new `ProcessBuilder` class generated.
public function newProcessBuilder2(string[] arg0) returns ProcessBuilder|error {
    handle externalObj = java_lang_ProcessBuilder_newProcessBuilder2(check jarrays:toHandle(arg0, "java.lang.String"));
    ProcessBuilder newObj = new (externalObj);
    return newObj;
}

# The function that maps to the `startPipeline` method of `java.lang.ProcessBuilder`.
#
# + arg0 - The `List` value required to map with the Java method parameter.
# + return - The `List` or the `IOException` value returning from the Java mapping.
public function ProcessBuilder_startPipeline(List arg0) returns List|IOException {
    handle|error externalObj = java_lang_ProcessBuilder_startPipeline(arg0.jObj);
    if (externalObj is error) {
        IOException e = error IOException(IOEXCEPTION, externalObj, message = externalObj.message());
        return e;
    } else {
        List newObj = new (externalObj);
        return newObj;
    }
}

function java_lang_ProcessBuilder_command(handle receiver) returns handle = @java:Method {
    name: "command",
    'class: "java.lang.ProcessBuilder",
    paramTypes: []
} external;

function java_lang_ProcessBuilder_command2(handle receiver, handle arg0) returns handle = @java:Method {
    name: "command",
    'class: "java.lang.ProcessBuilder",
    paramTypes: ["java.util.List"]
} external;

function java_lang_ProcessBuilder_command3(handle receiver, handle arg0) returns handle = @java:Method {
    name: "command",
    'class: "java.lang.ProcessBuilder",
    paramTypes: ["[Ljava.lang.String;"]
} external;

function java_lang_ProcessBuilder_directory(handle receiver) returns handle = @java:Method {
    name: "directory",
    'class: "java.lang.ProcessBuilder",
    paramTypes: []
} external;

function java_lang_ProcessBuilder_directory2(handle receiver, handle arg0) returns handle = @java:Method {
    name: "directory",
    'class: "java.lang.ProcessBuilder",
    paramTypes: ["java.io.File"]
} external;

function java_lang_ProcessBuilder_environment(handle receiver) returns handle = @java:Method {
    name: "environment",
    'class: "java.lang.ProcessBuilder",
    paramTypes: []
} external;

function java_lang_ProcessBuilder_equals(handle receiver, handle arg0) returns boolean = @java:Method {
    name: "equals",
    'class: "java.lang.ProcessBuilder",
    paramTypes: ["java.lang.Object"]
} external;

function java_lang_ProcessBuilder_getClass(handle receiver) returns handle = @java:Method {
    name: "getClass",
    'class: "java.lang.ProcessBuilder",
    paramTypes: []
} external;

function java_lang_ProcessBuilder_hashCode(handle receiver) returns int = @java:Method {
    name: "hashCode",
    'class: "java.lang.ProcessBuilder",
    paramTypes: []
} external;

function java_lang_ProcessBuilder_inheritIO(handle receiver) returns handle = @java:Method {
    name: "inheritIO",
    'class: "java.lang.ProcessBuilder",
    paramTypes: []
} external;

function java_lang_ProcessBuilder_notify(handle receiver) = @java:Method {
    name: "notify",
    'class: "java.lang.ProcessBuilder",
    paramTypes: []
} external;

function java_lang_ProcessBuilder_notifyAll(handle receiver) = @java:Method {
    name: "notifyAll",
    'class: "java.lang.ProcessBuilder",
    paramTypes: []
} external;

function java_lang_ProcessBuilder_redirectError(handle receiver) returns handle = @java:Method {
    name: "redirectError",
    'class: "java.lang.ProcessBuilder",
    paramTypes: []
} external;

function java_lang_ProcessBuilder_redirectError2(handle receiver, handle arg0) returns handle = @java:Method {
    name: "redirectError",
    'class: "java.lang.ProcessBuilder",
    paramTypes: ["java.io.File"]
} external;

function java_lang_ProcessBuilder_redirectError3(handle receiver, handle arg0) returns handle = @java:Method {
    name: "redirectError",
    'class: "java.lang.ProcessBuilder",
    paramTypes: ["java.lang.ProcessBuilder$Redirect"]
} external;

function java_lang_ProcessBuilder_redirectErrorStream(handle receiver) returns boolean = @java:Method {
    name: "redirectErrorStream",
    'class: "java.lang.ProcessBuilder",
    paramTypes: []
} external;

function java_lang_ProcessBuilder_redirectErrorStream2(handle receiver, boolean arg0) returns handle = @java:Method {
    name: "redirectErrorStream",
    'class: "java.lang.ProcessBuilder",
    paramTypes: ["boolean"]
} external;

function java_lang_ProcessBuilder_redirectInput(handle receiver) returns handle = @java:Method {
    name: "redirectInput",
    'class: "java.lang.ProcessBuilder",
    paramTypes: []
} external;

function java_lang_ProcessBuilder_redirectInput2(handle receiver, handle arg0) returns handle = @java:Method {
    name: "redirectInput",
    'class: "java.lang.ProcessBuilder",
    paramTypes: ["java.io.File"]
} external;

function java_lang_ProcessBuilder_redirectInput3(handle receiver, handle arg0) returns handle = @java:Method {
    name: "redirectInput",
    'class: "java.lang.ProcessBuilder",
    paramTypes: ["java.lang.ProcessBuilder$Redirect"]
} external;

function java_lang_ProcessBuilder_redirectOutput(handle receiver) returns handle = @java:Method {
    name: "redirectOutput",
    'class: "java.lang.ProcessBuilder",
    paramTypes: []
} external;

function java_lang_ProcessBuilder_redirectOutput2(handle receiver, handle arg0) returns handle = @java:Method {
    name: "redirectOutput",
    'class: "java.lang.ProcessBuilder",
    paramTypes: ["java.io.File"]
} external;

function java_lang_ProcessBuilder_redirectOutput3(handle receiver, handle arg0) returns handle = @java:Method {
    name: "redirectOutput",
    'class: "java.lang.ProcessBuilder",
    paramTypes: ["java.lang.ProcessBuilder$Redirect"]
} external;

function java_lang_ProcessBuilder_start(handle receiver) returns handle|error = @java:Method {
    name: "start",
    'class: "java.lang.ProcessBuilder",
    paramTypes: []
} external;

function java_lang_ProcessBuilder_startPipeline(handle arg0) returns handle|error = @java:Method {
    name: "startPipeline",
    'class: "java.lang.ProcessBuilder",
    paramTypes: ["java.util.List"]
} external;

function java_lang_ProcessBuilder_wait(handle receiver) returns error? = @java:Method {
    name: "wait",
    'class: "java.lang.ProcessBuilder",
    paramTypes: []
} external;

function java_lang_ProcessBuilder_wait2(handle receiver, int arg0) returns error? = @java:Method {
    name: "wait",
    'class: "java.lang.ProcessBuilder",
    paramTypes: ["long"]
} external;

function java_lang_ProcessBuilder_wait3(handle receiver, int arg0, int arg1) returns error? = @java:Method {
    name: "wait",
    'class: "java.lang.ProcessBuilder",
    paramTypes: ["long", "int"]
} external;

function java_lang_ProcessBuilder_newProcessBuilder1(handle arg0) returns handle = @java:Constructor {
    'class: "java.lang.ProcessBuilder",
    paramTypes: ["java.util.List"]
} external;

function java_lang_ProcessBuilder_newProcessBuilder2(handle arg0) returns handle = @java:Constructor {
    'class: "java.lang.ProcessBuilder",
    paramTypes: ["[Ljava.lang.String;"]
} external;

