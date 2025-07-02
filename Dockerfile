# Use OpenJDK 17 slim image
FROM openjdk:17-jdk-slim

# Set the working directory
WORKDIR /app

# Install Maven
RUN apt-get update && \
    apt-get install -y maven && \
    rm -rf /var/lib/apt/lists/*

# Copy Maven wrapper and pom.xml first to cache dependencies
COPY .mvn .mvn
COPY mvnw pom.xml ./

# Make mvnw executable
RUN chmod +x mvnw

# Download dependencies
RUN ./mvnw dependency:go-offline

# Copy all project files
COPY . .

# ✅ Make mvnw executable AGAIN (after full copy)
RUN chmod +x mvnw

# Build the application
RUN ./mvnw clean package -DskipTests

# Expose port
EXPOSE 9098

# Run the JAR
CMD ["sh", "-c", "java -jar $(find target -name '*-SNAPSHOT.jar' | head -n 1)"]
