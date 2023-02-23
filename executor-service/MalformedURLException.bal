// Ballerina error type for `java.net.MalformedURLException`.

public const MALFORMEDURLEXCEPTION = "MalformedURLException";

type MalformedURLExceptionData record {
    string message;
};

public type MalformedURLException distinct error<MalformedURLExceptionData>;

