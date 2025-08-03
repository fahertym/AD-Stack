import React from 'react';
import { Spinner, Bullseye } from '@patternfly/react-core';

interface LoadingSpinnerProps {
  size?: 'sm' | 'md' | 'lg' | 'xl';
  text?: string;
}

export const LoadingSpinner: React.FC<LoadingSpinnerProps> = ({ 
  size = 'lg', 
  text = 'Loading...' 
}) => {
  return (
    <Bullseye>
      <div style={{ textAlign: 'center' }}>
        <Spinner size={size} aria-label={text} />
        {text && (
          <div style={{ marginTop: '16px', fontSize: '14px', color: '#6a6e73' }}>
            {text}
          </div>
        )}
      </div>
    </Bullseye>
  );
};