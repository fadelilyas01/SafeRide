import { render, screen } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import Dashboard from '../components/Dashboard';

// Mock Recharts to avoid issues with JSDOM sizing
vi.mock('recharts', () => ({
  ResponsiveContainer: ({ children }) => <div>{children}</div>,
  AreaChart: ({ children }) => <div>{children}</div>,
  Area: () => <div />,
  XAxis: () => <div />,
  YAxis: () => <div />,
  CartesianGrid: () => <div />,
  Tooltip: () => <div />,
}));

describe('Dashboard Component', () => {
  it('renders the stat cards with correct titles', () => {
    render(<Dashboard />);
    
    expect(screen.getByText('Trajets Totaux')).toBeInTheDocument();
    expect(screen.getByText('Utilisateurs Actifs')).toBeInTheDocument();
    expect(screen.getByText('Revenus (CAD)')).toBeInTheDocument();
    expect(screen.getByText("Taux d'Acceptation")).toBeInTheDocument();
  });

  it('renders the kyc verification section', () => {
    render(<Dashboard />);
    
    expect(screen.getByText('Récentes Vérifications KYC')).toBeInTheDocument();
    expect(screen.getByText('Voir toutes les demandes')).toBeInTheDocument();
  });

  it('renders the weekly activity title', () => {
    render(<Dashboard />);
    expect(screen.getByText('Activité Hebdomadaire')).toBeInTheDocument();
  });
});
