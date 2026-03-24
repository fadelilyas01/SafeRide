import { render, screen, fireEvent } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import UserList from '../components/UserList';

describe('UserList Component', () => {
  it('renders correctly with default data', () => {
    render(<UserList />);
    
    expect(screen.getByText('Jean Tremblay')).toBeInTheDocument();
    expect(screen.getByText('Marie Côté')).toBeInTheDocument();
    expect(screen.getByPlaceholderText('Rechercher un utilisateur (nom, email...)')).toBeInTheDocument();
  });

  it('filters users by role', () => {
    render(<UserList />);
    
    const driverButton = screen.getByText('Conducteurs');
    const passengerButton = screen.getByText('Passagers');
    
    // Filter by drivers
    fireEvent.click(driverButton);
    expect(screen.getByText('Jean Tremblay')).toBeInTheDocument();
    expect(screen.queryByText('Marie Côté')).not.toBeInTheDocument();
    
    // Filter by passengers
    fireEvent.click(passengerButton);
    expect(screen.queryByText('Jean Tremblay')).not.toBeInTheDocument();
    expect(screen.getByText('Marie Côté')).toBeInTheDocument();
  });

  it('shows correct verification status icons', () => {
    render(<UserList />);
    
    // Jean Tremblay is verified
    expect(screen.getByText('verified')).toBeInTheDocument();
    // Luc Roy is pending
    expect(screen.getByText('pending')).toBeInTheDocument();
  });
});
