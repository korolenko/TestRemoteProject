import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

public class TestJSONParser {
    public static void main(String[] args) throws IOException {

        //configure ObjectMapper
        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);

        //read data from json-file
        byte[] jsonData = Files.readAllBytes(Paths.get("testJSON.json"));

        //write previously read data to Table class
        Table table = objectMapper.readValue(jsonData, Table.class);

        //show the result
        System.out.println(table.toString());
    }
}
