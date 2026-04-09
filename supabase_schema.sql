-- ==========================================
-- SafeRide MVP - Supabase SQL Schema
-- ==========================================

-- 1. Table Utilisateurs (Profils étendus de auth.users)
CREATE TABLE public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    role TEXT NOT NULL CHECK (role IN ('RIDER', 'DRIVER', 'ADMIN')),
    first_name TEXT,
    last_name TEXT,
    phone TEXT UNIQUE,
    trust_score NUMERIC(3,2) DEFAULT 5.0,
    is_kyc_verified BOOLEAN DEFAULT FALSE,
    is_women_safe BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Active RLS sur la table profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Politique : Un utilisateur peut voir son propre profil
CREATE POLICY "Users can view their own profile." 
ON public.profiles FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile." 
ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- 2. Table des Véhicules (Pour les Drivers)
CREATE TABLE public.vehicles (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    driver_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    brand TEXT NOT NULL,
    model TEXT NOT NULL,
    license_plate TEXT NOT NULL UNIQUE,
    color TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

ALTER TABLE public.vehicles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Drivers manage their vehicles" ON public.vehicles FOR ALL USING (auth.uid() = driver_id);

-- 3. Trigger pour créer automatiquement un profil après inscription (Signup)
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, role, phone)
  VALUES (new.id, 'RIDER', new.phone); -- Par défaut le rôle est Passenger (RIDER)
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- ==========================================
-- 4. Table des Trajets (Rides)
-- ==========================================
CREATE TABLE public.rides (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    rider_id UUID REFERENCES public.profiles(id) NOT NULL,
    driver_id UUID REFERENCES public.profiles(id),
    pickup_address TEXT NOT NULL,
    pickup_lat NUMERIC NOT NULL,
    pickup_lng NUMERIC NOT NULL,
    dropoff_address TEXT NOT NULL,
    dropoff_lat NUMERIC NOT NULL,
    dropoff_lng NUMERIC NOT NULL,
    status TEXT NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'ACCEPTED', 'ARRIVED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
    price NUMERIC(10,2) NOT NULL,
    otp_code VARCHAR(4),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

ALTER TABLE public.rides ENABLE ROW LEVEL SECURITY;

-- Les passagers peuvent voir et modifier leurs propres trajets
CREATE POLICY "Riders can view own rides" ON public.rides FOR SELECT USING (auth.uid() = rider_id);
CREATE POLICY "Riders can insert rides" ON public.rides FOR INSERT WITH CHECK (auth.uid() = rider_id);

-- Les chauffeurs peuvent voir les trajets 'PENDING' ou leurs propres trajets
CREATE POLICY "Drivers can view pending or assigned rides" ON public.rides FOR SELECT USING (
  status = 'PENDING' OR auth.uid() = driver_id
);
CREATE POLICY "Drivers can update rides" ON public.rides FOR UPDATE USING (
  status = 'PENDING' OR auth.uid() = driver_id
);

-- ==========================================
-- 5. Table des Messages de Chat (Temps réel)
-- ==========================================
CREATE TABLE public.chat_messages (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    ride_id UUID REFERENCES public.rides(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES public.profiles(id),
    message TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read chat messages for their rides" 
ON public.chat_messages FOR SELECT USING (
  ride_id IN (SELECT id FROM public.rides WHERE rider_id = auth.uid() OR driver_id = auth.uid())
);
CREATE POLICY "Users can insert chat messages for their rides" 
ON public.chat_messages FOR INSERT WITH CHECK (
  ride_id IN (SELECT id FROM public.rides WHERE rider_id = auth.uid() OR driver_id = auth.uid())
);

-- Accessing Supabase Realtime for Chat Messages features
BEGIN;
  DROP PUBLICATION IF EXISTS supabase_realtime;
  CREATE PUBLICATION supabase_realtime;
COMMIT;
ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_messages;

-- ==========================================
-- 6. Table des Logs d'Audit
-- ==========================================
CREATE TABLE public.audit_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    action TEXT NOT NULL,
    target_id UUID,
    actor_id UUID REFERENCES auth.users(id),
    status TEXT DEFAULT 'SUCCESS',
    details JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Security for audit logs (only admins or service_role can read)
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Only admins view audit logs" ON public.audit_logs FOR SELECT USING (
  EXISTS(SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'ADMIN')
);
CREATE POLICY "Anyone can insert audit logs" ON public.audit_logs FOR INSERT WITH CHECK (true);
