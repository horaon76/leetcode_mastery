### Low-Level Design (LLD) for a Parking Lot in Java

When designing a parking lot system, we aim to make it flexible, maintainable, and scalable. The system must handle multiple vehicles and parking spaces, compute parking charges, and ensure proper vehicle entry and exit. We'll break down the design into classes, relationships, and behavior.

### Functional Requirements:
1. The parking lot should support different types of vehicles (car, bike, truck, etc.).
2. The system should be able to assign the nearest available parking spot.
3. The system should compute the parking fee based on the time spent.
4. The parking lot should have multiple floors and spots.
5. The system should track vehicles entering and exiting.

### Non-Functional Requirements:
1. The design should be flexible to add new types of vehicles.
2. It should be scalable to handle large parking lots with multiple floors.
3. The design should follow Object-Oriented Principles (OOP) like SOLID.

### Key Classes and Design

#### 1. **ParkingLot**
   - The `ParkingLot` class represents the entire parking structure and contains the list of floors.
   - It tracks the total number of parking spaces and manages vehicle entry/exit.

```java
public class ParkingLot {
    private List<ParkingFloor> floors;
    private String parkingLotName;

    public ParkingLot(String parkingLotName, int numberOfFloors) {
        this.parkingLotName = parkingLotName;
        this.floors = new ArrayList<>();
        for (int i = 1; i <= numberOfFloors; i++) {
            floors.add(new ParkingFloor(i));
        }
    }

    public boolean parkVehicle(Vehicle vehicle) {
        for (ParkingFloor floor : floors) {
            if (floor.parkVehicle(vehicle)) {
                return true;
            }
        }
        return false; // Parking is full
    }

    public boolean unParkVehicle(Vehicle vehicle) {
        for (ParkingFloor floor : floors) {
            if (floor.unParkVehicle(vehicle)) {
                return true;
            }
        }
        return false; // Vehicle not found
    }
}
```

#### 2. **ParkingFloor**
   - Represents a single floor within the parking lot. Each floor has multiple parking spots.
   
```java
public class ParkingFloor {
    private int floorNumber;
    private List<ParkingSpot> spots;

    public ParkingFloor(int floorNumber) {
        this.floorNumber = floorNumber;
        this.spots = new ArrayList<>();
        // Initialize parking spots for the floor
        initializeSpots();
    }

    private void initializeSpots() {
        for (int i = 1; i <= 20; i++) { // 20 spots per floor
            spots.add(new ParkingSpot(i, SpotType.CAR)); // Default to car spots
        }
    }

    public boolean parkVehicle(Vehicle vehicle) {
        for (ParkingSpot spot : spots) {
            if (spot.isAvailable() && spot.canFitVehicle(vehicle)) {
                spot.assignVehicle(vehicle);
                return true;
            }
        }
        return false; // No available spot on this floor
    }

    public boolean unParkVehicle(Vehicle vehicle) {
        for (ParkingSpot spot : spots) {
            if (!spot.isAvailable() && spot.getVehicle().equals(vehicle)) {
                spot.removeVehicle();
                return true;
            }
        }
        return false; // Vehicle not found on this floor
    }
}
```

#### 3. **ParkingSpot**
   - Each parking spot holds a vehicle and knows whether it is occupied or not.

```java
public class ParkingSpot {
    private int spotNumber;
    private SpotType type;
    private Vehicle vehicle;

    public ParkingSpot(int spotNumber, SpotType type) {
        this.spotNumber = spotNumber;
        this.type = type;
        this.vehicle = null;
    }

    public boolean isAvailable() {
        return vehicle == null;
    }

    public boolean canFitVehicle(Vehicle vehicle) {
        return this.type.canFitVehicle(vehicle);
    }

    public void assignVehicle(Vehicle vehicle) {
        this.vehicle = vehicle;
    }

    public void removeVehicle() {
        this.vehicle = null;
    }

    public Vehicle getVehicle() {
        return this.vehicle;
    }
}
```

#### 4. **Vehicle**
   - Base class for different types of vehicles.
   
```java
public abstract class Vehicle {
    private String licensePlate;
    private VehicleSize size;

    public Vehicle(String licensePlate, VehicleSize size) {
        this.licensePlate = licensePlate;
        this.size = size;
    }

    public String getLicensePlate() {
        return licensePlate;
    }

    public VehicleSize getSize() {
        return size;
    }
}

public class Car extends Vehicle {
    public Car(String licensePlate) {
        super(licensePlate, VehicleSize.COMPACT);
    }
}

public class Bike extends Vehicle {
    public Bike(String licensePlate) {
        super(licensePlate, VehicleSize.SMALL);
    }
}

public class Truck extends Vehicle {
    public Truck(String licensePlate) {
        super(licensePlate, VehicleSize.LARGE);
    }
}
```

#### 5. **SpotType** and **VehicleSize**
   - Enumerations to represent the type of spot and vehicle size.
   
```java
public enum SpotType {
    CAR, BIKE, TRUCK;

    public boolean canFitVehicle(Vehicle vehicle) {
        switch (this) {
            case CAR:
                return vehicle.getSize() == VehicleSize.COMPACT;
            case BIKE:
                return vehicle.getSize() == VehicleSize.SMALL;
            case TRUCK:
                return vehicle.getSize() == VehicleSize.LARGE;
            default:
                return false;
        }
    }
}

public enum VehicleSize {
    SMALL, COMPACT, LARGE;
}
```

#### 6. **ParkingTicket**
   - Each vehicle is assigned a parking ticket upon entry. This ticket tracks entry time and is used to compute the total parking duration.

```java
import java.time.LocalDateTime;

public class ParkingTicket {
    private String ticketId;
    private LocalDateTime entryTime;
    private LocalDateTime exitTime;
    private Vehicle vehicle;
    private ParkingSpot spot;

    public ParkingTicket(Vehicle vehicle, ParkingSpot spot) {
        this.ticketId = generateTicketId();
        this.vehicle = vehicle;
        this.spot = spot;
        this.entryTime = LocalDateTime.now();
    }

    public void markExit() {
        this.exitTime = LocalDateTime.now();
    }

    public long calculateDuration() {
        if (exitTime == null) {
            throw new IllegalStateException("Vehicle has not exited yet.");
        }
        return java.time.Duration.between(entryTime, exitTime).toMinutes();
    }

    private String generateTicketId() {
        return "TICKET-" + System.currentTimeMillis();
    }

    public Vehicle getVehicle() {
        return vehicle;
    }
}
```

#### 7. **ParkingChargeCalculator**
   - This class computes the total fee based on the duration and the type of vehicle.

```java
public class ParkingChargeCalculator {
    private static final int BASE_RATE = 10; // Base rate per hour

    public static int calculateFee(ParkingTicket ticket) {
        long durationInMinutes = ticket.calculateDuration();
        int hours = (int) Math.ceil(durationInMinutes / 60.0);

        Vehicle vehicle = ticket.getVehicle();
        int rate = BASE_RATE;

        if (vehicle instanceof Truck) {
            rate *= 3; // Trucks have a higher rate
        } else if (vehicle instanceof Bike) {
            rate /= 2; // Bikes have a lower rate
        }
        return rate * hours;
    }
}
```

### Summary of Classes:
- `ParkingLot`: Manages parking floors and entry/exit of vehicles.
- `ParkingFloor`: Manages parking spots on a particular floor.
- `ParkingSpot`: Holds information about each individual parking spot.
- `Vehicle`: Base class for all types of vehicles (Bike, Car, Truck).
- `ParkingTicket`: Tracks the entry, exit, and duration for each vehicle.
- `ParkingChargeCalculator`: Computes the fee based on time and vehicle type.
- `SpotType` & `VehicleSize`: Enum types to represent spot and vehicle sizes.

### Key Design Principles:
- **Single Responsibility Principle**: Each class has a single responsibility, like `ParkingLot` manages floors, and `ParkingSpot` manages vehicle allocation.
- **Open/Closed Principle**: It’s easy to extend the system to add more vehicle types without modifying existing code.
- **Encapsulation**: Each class hides its internal workings and provides public methods to interact with other classes.
  
This design can be scaled up by adding more features like payment systems, reserved parking, and integration with IoT systems.