-- Supabase Database Schema for Estudify
-- Run these commands in your Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create enum types
CREATE TYPE room_status AS ENUM ('available', 'occupied', 'maintenance');
CREATE TYPE reservation_status AS ENUM ('active', 'cancelled', 'completed', 'expired');

-- Create rooms table
CREATE TABLE rooms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    capacity INTEGER NOT NULL CHECK (capacity > 0),
    status room_status DEFAULT 'available',
    amenities TEXT[] DEFAULT ARRAY[]::TEXT[],
    image_url TEXT,
    location VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create reservations table
CREATE TABLE reservations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    status reservation_status DEFAULT 'active',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT valid_time_range CHECK (end_time > start_time),
    CONSTRAINT valid_duration CHECK (end_time - start_time <= INTERVAL '8 hours'),
    CONSTRAINT future_reservation CHECK (start_time > NOW())
);

-- Create indexes for better performance
CREATE INDEX idx_rooms_status ON rooms(status);
CREATE INDEX idx_rooms_capacity ON rooms(capacity);
CREATE INDEX idx_reservations_user_id ON reservations(user_id);
CREATE INDEX idx_reservations_room_id ON reservations(room_id);
CREATE INDEX idx_reservations_start_time ON reservations(start_time);
CREATE INDEX idx_reservations_end_time ON reservations(end_time);
CREATE INDEX idx_reservations_status ON reservations(status);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_rooms_updated_at 
    BEFORE UPDATE ON rooms 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reservations_updated_at 
    BEFORE UPDATE ON reservations 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to get available rooms for a time period
CREATE OR REPLACE FUNCTION get_available_rooms(
    start_time TIMESTAMP WITH TIME ZONE,
    end_time TIMESTAMP WITH TIME ZONE
)
RETURNS TABLE(
    id UUID,
    name VARCHAR(255),
    description TEXT,
    capacity INTEGER,
    status room_status,
    amenities TEXT[],
    image_url TEXT,
    location VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT r.id, r.name, r.description, r.capacity, r.status, 
           r.amenities, r.image_url, r.location, r.created_at, r.updated_at
    FROM rooms r
    WHERE r.status = 'available'
    AND r.id NOT IN (
        SELECT res.room_id
        FROM reservations res
        WHERE res.status = 'active'
        AND (
            (res.start_time <= start_time AND res.end_time > start_time) OR
            (res.start_time < end_time AND res.end_time >= end_time) OR
            (res.start_time >= start_time AND res.end_time <= end_time)
        )
    )
    ORDER BY r.name;
END;
$$ LANGUAGE plpgsql;

-- Function to check if a room is available
CREATE OR REPLACE FUNCTION is_room_available(
    room_id UUID,
    start_time TIMESTAMP WITH TIME ZONE,
    end_time TIMESTAMP WITH TIME ZONE
)
RETURNS BOOLEAN AS $$
DECLARE
    conflict_count INTEGER;
    room_status_val room_status;
BEGIN
    -- Check if room exists and is available
    SELECT status INTO room_status_val FROM rooms WHERE id = room_id;
    
    IF room_status_val IS NULL OR room_status_val != 'available' THEN
        RETURN FALSE;
    END IF;
    
    -- Check for conflicting reservations
    SELECT COUNT(*) INTO conflict_count
    FROM reservations
    WHERE room_id = is_room_available.room_id
    AND status = 'active'
    AND (
        (start_time <= is_room_available.start_time AND end_time > is_room_available.start_time) OR
        (start_time < is_room_available.end_time AND end_time >= is_room_available.end_time) OR
        (start_time >= is_room_available.start_time AND end_time <= is_room_available.end_time)
    );
    
    RETURN conflict_count = 0;
END;
$$ LANGUAGE plpgsql;

-- Function to automatically expire past reservations
CREATE OR REPLACE FUNCTION expire_past_reservations()
RETURNS INTEGER AS $$
DECLARE
    expired_count INTEGER;
BEGIN
    UPDATE reservations 
    SET status = 'expired'
    WHERE status = 'active' 
    AND end_time < NOW();
    
    GET DIAGNOSTICS expired_count = ROW_COUNT;
    RETURN expired_count;
END;
$$ LANGUAGE plpgsql;

-- Function to complete ongoing reservations that have ended
CREATE OR REPLACE FUNCTION complete_ended_reservations()
RETURNS INTEGER AS $$
DECLARE
    completed_count INTEGER;
BEGIN
    UPDATE reservations 
    SET status = 'completed'
    WHERE status = 'active' 
    AND end_time <= NOW()
    AND start_time <= NOW();
    
    GET DIAGNOSTICS completed_count = ROW_COUNT;
    RETURN completed_count;
END;
$$ LANGUAGE plpgsql;

-- Create a scheduled job to run cleanup functions (if pg_cron is available)
-- Note: This requires the pg_cron extension which may not be available in all Supabase plans
-- SELECT cron.schedule('expire-reservations', '*/15 * * * *', 'SELECT expire_past_reservations();');
-- SELECT cron.schedule('complete-reservations', '*/15 * * * *', 'SELECT complete_ended_reservations();');

-- Insert sample rooms
INSERT INTO rooms (name, description, capacity, status, amenities, location) VALUES
('Sala A-101', 'Sala de estudio grupal con pizarra y proyector', 8, 'available', ARRAY['Pizarra', 'Proyector', 'WiFi', 'Aire acondicionado'], 'Edificio A, Piso 1'),
('Sala A-102', 'Sala pequeña ideal para estudio individual o parejas', 2, 'available', ARRAY['WiFi', 'Silenciosa'], 'Edificio A, Piso 1'),
('Sala B-201', 'Sala multimedia con computadoras y pantalla grande', 12, 'available', ARRAY['Computadoras', 'Pantalla grande', 'WiFi', 'Proyector'], 'Edificio B, Piso 2'),
('Sala B-202', 'Sala de reuniones con mesa de conferencias', 6, 'available', ARRAY['Mesa de conferencias', 'WiFi', 'Pizarra'], 'Edificio B, Piso 2'),
('Sala C-301', 'Sala de estudio silenciosa', 4, 'available', ARRAY['Silenciosa', 'WiFi', 'Enchufes'], 'Edificio C, Piso 3'),
('Sala C-302', 'Sala con vista al jardín', 10, 'available', ARRAY['Vista al jardín', 'WiFi', 'Pizarra', 'Aire acondicionado'], 'Edificio C, Piso 3');

-- Row Level Security (RLS) policies

-- Enable RLS on tables
ALTER TABLE rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE reservations ENABLE ROW LEVEL SECURITY;

-- Policies for rooms table
CREATE POLICY "Rooms are viewable by everyone" ON rooms
    FOR SELECT USING (true);

-- Policies for reservations table
CREATE POLICY "Users can view own reservations" ON reservations
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own reservations" ON reservations
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own reservations" ON reservations
    FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own reservations" ON reservations
    FOR DELETE USING (auth.uid() = user_id);

-- Create a view for reservations with room and user details
CREATE VIEW reservation_details AS
SELECT 
    r.*,
    rm.name as room_name,
    rm.location as room_location,
    rm.capacity as room_capacity,
    u.email as user_email,
    u.raw_user_meta_data->>'name' as user_name
FROM reservations r
JOIN rooms rm ON r.room_id = rm.id
JOIN auth.users u ON r.user_id = u.id;

-- Grant necessary permissions
GRANT SELECT ON reservation_details TO authenticated;

-- Create notification function for reservation changes
CREATE OR REPLACE FUNCTION notify_reservation_change()
RETURNS TRIGGER AS $$
BEGIN
    -- This could be extended to send actual notifications
    -- For now, it just logs the change
    IF TG_OP = 'INSERT' THEN
        INSERT INTO reservations_log (reservation_id, action, created_at)
        VALUES (NEW.id, 'created', NOW());
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO reservations_log (reservation_id, action, created_at)
        VALUES (NEW.id, 'updated', NOW());
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO reservations_log (reservation_id, action, created_at)
        VALUES (OLD.id, 'deleted', NOW());
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create reservations log table for tracking changes
CREATE TABLE reservations_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reservation_id UUID,
    action VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create trigger for reservation notifications
CREATE TRIGGER reservation_change_trigger
    AFTER INSERT OR UPDATE OR DELETE ON reservations
    FOR EACH ROW EXECUTE FUNCTION notify_reservation_change();

-- Create function to prevent overlapping reservations
CREATE OR REPLACE FUNCTION prevent_overlapping_reservations()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT is_room_available(NEW.room_id, NEW.start_time, NEW.end_time) THEN
        RAISE EXCEPTION 'Room is not available for the selected time period';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to prevent overlapping reservations
CREATE TRIGGER prevent_overlap_trigger
    BEFORE INSERT OR UPDATE ON reservations
    FOR EACH ROW EXECUTE FUNCTION prevent_overlapping_reservations();

-- Comments for documentation
CREATE_FILE_OUTPUT_TOO_LONG
