import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.log4j.Logger;


import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

public class TestJSONParser {
    private final static Logger logger = Logger.getLogger(TestJSONParser.class);

    public static void main(String[] args) throws IOException {
        String JSONFile = "testJSON.json";
        String DDLTemplate = "test_DDL_template.sql";

        //configure ObjectMapper
        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);

        try{
            //read data from json-file
            byte[] jsonData = Files.readAllBytes(Paths.get(JSONFile));

            //write previously read data to Table class
            Table table = objectMapper.readValue(jsonData, Table.class);

            //show the result
            logger.info(JSONFile + " has been parsed successfully:");
            logger.info(table.toString());

            //read table DDL template
            Path path = Paths.get(DDLTemplate);
            Charset charset = StandardCharsets.UTF_8;

            //replace attributes in ddl template
            String content = new String(Files.readAllBytes(path), charset);
            content = content.replaceAll("table_name" , table.getTableName());
            content = content.replaceAll("attributes" , table.getAttributes());

            //create ddl file
            Files.write(Paths.get(table.getTableName() + "_DDL.sql"), content.getBytes(charset));
            logger.info("ddl file "
                        + table.getTableName()
                        + "_DDL.sql has been created successfully");
        }catch (IOException e) {
            logger.error(e);
        }
    }
}
